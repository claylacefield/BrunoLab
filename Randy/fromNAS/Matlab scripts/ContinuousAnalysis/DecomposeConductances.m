function [g_e, g_i, g_tot] = DecomposeConductances(Cm, average, x, current, stimOnset)

% DECOMPOSECONDUCTANCES
% This script extends MeasureRiUsingDCcurrents to decompose the total
% conductance change into excitatory and inhibitory conductances.
% Measures over the course of an entire trial by comparing two or more
% averaged continuous traces at varying levels of DC current injection.
% See Higley & Contreras 2006 Jneurosci.
%
% INPUTS - user will be prompted for datafiles if no parameters are supplied
% Cm: the capacitance of the cell in Farads (e.g., from "hyp 100pA short"
% recording)
% average: time x nCurrentLevels array of averaged membrane potential
% current: numeric array indicating current levels in pA
% x: timebase for average

% stimOnset: onset time of stimulus (laser or whisker) in msecs
%
% OUTPUTS
% g_e: estimated excitatory conductance
% g_i: estimated inhibitory conductance
% g_tot: measured total conductance
%
% Randy Bruno, May 2013

SAMPLERATE = 32000; % in Hz
samples_per_ms = SAMPLERATE / 1000;

%% user must select datafiles if no input parameters are given
if nargin == 0
    % first, get Cm from standard input resistance measurement file
    [filename pathname OK] = uigetfile('*.dat', 'Select input resistance measurement file (CANCEL sets Cm to 0)');
    if OK
        pulsepath = [pathname, filename];
        figure; [Ri_pulse, tau_pulse] = measureRi(pulsepath, 200, 50, 100, 150);
        Cm = tau_pulse/Ri_pulse * 10^-9; % multiplying by 10^9 converts nF to F
    else
        % User may elect to set Cm to 0 by canceling file selection dialog.
        Cm = 0;
    end
    
    % second, ask user how the DC current injections were recorded (1 or
    % many files)
    button = questdlg('Are the DC current injections recorded into one or separate files?', ...
        '','one','separate', 'cancel', 'one');
    switch button
        case 'cancel'
            return;
        case 'separate'           
            % ask user for files with DC current injections (including 0 nA)
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
            
            % average each DC current injection file

            nScans = SAMPLERATE * (duration / 1000);
            average = nans(nScans, nfiles);
            for i = 1:nfiles
                stimcodes = GetStimCodes(filepath{i}, duration);
                stimcode = stimcodes(stimcodes <= -5000);
                figure;
                [average(:,i), x] = MeanContinuous(filepath{i}, duration, stimOnset, true, stimcode);
                title(['injected ' num2str(current(i)) ' pA']);
            end
        case 'one'
            [filename pathname OK] = uigetfile('*.dat', 'Select DC current injection file');
            if ~OK
                return
            end
            filepath = [pathname, filename];
            
            % third, ask for parameters of DC current injection files
            answers = inputdlg({'Duration (ms)', 'Stimulus Onset (ms)'}, ...
                'Parameters for measuring Ri', 1, {'500', '250'});
            duration = str2num(answers{1});
            stimOnset = str2num(answers{2});
            [average, x, stimuli] = MeanContinuousByStim(filepath, duration);
            current = stimuli + 5000;
    end
    
    % downsample from 32k to 4k
    % DOWNSAMPLE = 8;
    % avg = nans(nScans/DOWNSAMPLE, nfiles);
    % for i = 1:nfiles
    %     avg(:,i) = decimate(average(:,i), DOWNSAMPLE);
    % end
    % samples_per_ms = samples_per_ms / DOWNSAMPLE;
    % average = avg;
    % x = linspace(0, duration, nScans / DOWNSAMPLE);
end

% check that there are no duplicate current level entries
if length(current) ~= length(unique(current))
    errordlg(['current levels must be unique:' num2str(current)]);
    return
end

%% calculate Ri timecourse
%  (adapted from Brian DePasquale's parallelconductance.m)

%empty vectors and static variables
equ1_betas = zeros(2,size(average,1));
xy_int = zeros(2,size(average,1));
I = zeros(size(average,1),size(average,2));
V = zeros(size(average,1),size(average,2));

%calculate dv/dt
dv = diff(average,1,1); %mV

%add the first difference onto the beginning to make it match up with the
%length of membrane potential trace
dv = [dv(1,:); dv];
dv_dt = (dv*10^-3/10^-3*(1/samples_per_ms)); %V/s

warning off stats:regress:RankDefDesignMat

%THIS REGRESSES THE AVERAGE (ACROSS TRIALS) INPUT CURRENT AGAINST THE 
%AVERAGE (ACROSS TRIALS) VOLTAGE. THE Y-INTERCEPT GIVES THE
%REVERSAL POTENTIAL FOR THE WHOLE MEMBRANE, THE INVERSE OF THE SLOPE GIVES
%THE TOTAL CONDUCTANCE. -BD
%I think Brian was wrong in his comment about the Y-intercept. Vrev is
%actually the intercept of two lines, as he calculates later in the code.
ntimepts = size(average, 1);
for i=1:ntimepts % iterates over time
    I(i,:) = 10^-12 * current - Cm .* dv_dt(i,:);
    V(i,:) = 10^-3 * average(i,:);   
    equ1_betas(:,i) = regress(V(i,:)', [ones(1,length(I(i,:))); I(i,:)]');
end
slope = equ1_betas(2,:); % slope is input resistance in units of Ohms
g_tot = 1./slope; % units of Siemens
slope = slope/10^6; % convert Ohms to MOhms

%% plot Ri results
figure;
subplot(3,1,1); plot(x, slope); xlabel('msec'); ylabel('R (MOhm)');
hold on; line([stimOnset stimOnset], [min(slope) max(slope)]);

slope = slope - mean(slope(x > stimOnset-10 & x < stimOnset));
subplot(3,1,2); plot(x, slope); xlabel('msec'); ylabel('delta R (MOhm)');
hold on; line([stimOnset stimOnset], [min(slope) max(slope)]);

slope = BoxcarFilter(slope, samples_per_ms * 10); % smooth
subplot(3,1,3); plot(x, slope); xlabel('msec'); ylabel('delta R (MOhm)');
hold on; line([stimOnset stimOnset], [min(slope) max(slope)]);

%% calculate excitatory and inhibitory conductances (g_e and g_i)

answers = inputdlg({'assumed excitatatory reversal (mV)', ...
    'assumed inhibitory reversal (mV)'}, ...
    'reversals', 1, {'0', '-80'});
v_e = str2num(answers{1});
v_i = str2num(answers{2});

% use of constants here is a holdover from Brian DePasquale's
% implementation of calculations
v_rev_clip_thresh = [v_e + 20 v_i - 100];
stimulation_time = stimOnset; % time of laser or whisker stimulus in msecs
g_rest_time = -1; % msecs before stimulation time to use in estimating resting conductance
baseline_time = -1; % not sure that baseline and g_rest are really different in BD's code
baseline_idx = (stimulation_time + baseline_time)*samples_per_ms;

for i=1:size(average,1)
    %xy_int(:,i) = [1, -equ1_betas(2,baseline_idx); 1, -equ1_betas(2,i)]\[equ1_betas(1,baseline_idx);equ1_betas(1,i)];
    xy_int(:,i) = [-equ1_betas(2,baseline_idx),1;-equ1_betas(2,i),1]\[equ1_betas(1,baseline_idx);equ1_betas(1,i)];
end

%v_rev = 10^3*xy_int(1,:);
v_rev = 10^3*xy_int(2,:);
%v_rev_clipped gets rid of all values outside of a reasonable range due
%to the artifact in calculated vrev for small conductance changes.
%basically, vrev is calculated as the intersection of two lines: the V-I
%curve at baseline, and the V-I curve at different times after that
%if the V-I curves are close, but not exact due to a small transient
%conductance change, the solution is just a numerical artifact and noisy
%we troubleshooted this for a while and came to this conclusion after many
%days of contemplation - BD
v_rev_clipped = v_rev;
v_rev_clipped(v_rev_clipped > v_rev_clip_thresh(1)) = NaN;
v_rev_clipped(v_rev_clipped < v_rev_clip_thresh(2)) = NaN;

% average everything from g_rest_idx time to whisker_stimulation time
g_rest = mean(g_tot((stimulation_time + g_rest_time)*samples_per_ms:stimulation_time*samples_per_ms));
disp(['g_rest = ' num2str(g_rest)])

g_syn = g_tot - g_rest;
g_i = (g_syn .* (v_e - v_rev))/(v_e - v_i);
g_e = (g_syn .* (v_rev - v_i))/(v_e - v_i);

figure;
subplot(3,1,1); plot(x, v_rev_clipped); ylabel('V_{rev} (mV)');
subplot(3,1,2); plot(x, g_syn * 10^9); ylabel('\Delta g_{total} (nS)');
subplot(3,1,3); plot(x, g_i * 10^9, 'r'); ylabel('\Delta g (nS)');
hold on; plot(x, g_e * 10^9, 'g'); legend('g_{I}', 'g_{E}');
xlabel('msec');
