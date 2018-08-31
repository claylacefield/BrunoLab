function MeasureRiUsingDCcurrents

% MEASURERIUSINGDCCURRENTS
% Measure input resistance over the course of an entire trial
% by comparing two or more averaged continuous traces at varying levels of
% DC current injection. See Higley & Contreras 2006 Jneurosci.
%
% Randy Bruno, July 2012

%% user input

% first, get Cm from standard input resistance measurement file
[filename pathname OK] = uigetfile('*.dat', 'Select input resistance measurement file');
if ~OK return; end % return if user cancels
pulsepath = [pathname, filename];
figure; [Ri_pulse, tau_pulse] = measureRi(pulsepath, 200, 50, 100, 150);
Cm_exp = tau_pulse/Ri_pulse * 10^-9; % multiplying by 10^9 converts nF to F
%Cm_exp = 0;
%don't actually seem to need Cm, could probably dispense with pulse file

% second, ask user for files with DC current injections (including 0 nA)
nfiles = 0;
OK = true;
while OK % end loop when user cancels
    [filename pathname OK] = uigetfile('*.dat', 'Select DC current injection file (CANCEL when done)');
    if OK
        nfiles = nfiles + 1;
        filepath{nfiles} = [pathname, filename];
        answers = inputdlg({'DC current injected (pA)'}, ...
            ['Parameters for file ' num2str(nfiles)], 1, {'0'});
        current(nfiles) = str2num(answers{1});
    end
end

% third, ask for parameters of DC current injection files
answers = inputdlg({'Duration (ms)', 'Stimulus Onset (ms)'}, ...
    'Parameters for measuring Ri', 1, {'500', '250'});
duration = str2num(answers{1});
stimOnset = str2num(answers{2});

%% average each DC current injection file

SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);

average = nans(nScans, nfiles);
for i = 1:nfiles
    stimcodes = GetStimCodes(filepath{i}, duration);
    stimcode = stimcodes(stimcodes <= -5000);
    figure;
    [average(:,i), x] = MeanContinuous(filepath{i}, duration, stimOnset, true, stimcode);
    title(['injected ' num2str(current(i)) ' pA']);
end

%% calculate Ri timecourse
%  (adapted from Brian DePasquale's parallelconductance.m)

steps_per_ms = SAMPLERATE / 1000; %Brian probably meant scans_per_ms

%empty vectors and static variables
equ1_betas = zeros(2,size(average,1));
xy_int = zeros(2,size(average,1));
x1_reg = zeros(size(average,1),size(average,2));
y1_reg = zeros(size(average,1),size(average,2));

%calculate dv/dt
dv = diff(average,1,1); %mV

%add the first difference onto the beginning to make it match up with the
%length of membrane potential trace
dv = [dv(1,:); dv];
dv_dt = (dv*10^-3/10^-3*(1/steps_per_ms)); %V/s

warning off stats:regress:RankDefDesignMat

%THIS REGRESSES THE AVERAGE (ACROSS TRIALS) INPUT CURRENT AGAINST THE 
%AVERAGE (ACROSS TRIALS) VOLTAGE. THE Y-INTERCEPT GIVES THE
%REVERSAL POTENTIAL FOR THE WHOLE MEMBRANE, THE INVERSE OF THE SLOPE GIVES
%THE TOTAL CONDUCTANCE
ntimepts = size(average, 1);
for i=1:ntimepts % iterates over time
    %x1_reg(i,:) = 10^-9 * current_pulse(i,:) - Cm_exp.*dv_dt(i,:);
    x1_reg(i,:) = 10^-12 * current - Cm_exp .* dv_dt(i,:);
    y1_reg(i,:) = 10^-3 * average(i,:);   
    equ1_betas(:,i) = regress(y1_reg(i,:)', ...
        [ones(1,length(x1_reg(i,:)));x1_reg(i,:)]');
end

y_int = equ1_betas(1,:); % intercept is cell's reversal potential
slope = equ1_betas(2,:); % slope is input resistance
%g_tot = 1./slope; % 1/slope --> g_tot

%% plot results
slope = slope/10^6; % convert Ohms to MOhms
figure;
subplot(3,1,1); plot(x, slope); xlabel('msec'); ylabel('R (MOhm)');
hold on; line([stimOnset stimOnset], [min(slope) max(slope)]);

slope = slope - mean(slope(x > stimOnset-10 & x < stimOnset));
subplot(3,1,2); plot(x, slope); xlabel('msec'); ylabel('delta R (MOhm)');
hold on; line([stimOnset stimOnset], [min(slope) max(slope)]);

slope = BoxcarFilter(slope, steps_per_ms * 10); % smooth
subplot(3,1,3); plot(x, slope); xlabel('msec'); ylabel('delta R (MOhm)');
hold on; line([stimOnset stimOnset], [min(slope) max(slope)]);
