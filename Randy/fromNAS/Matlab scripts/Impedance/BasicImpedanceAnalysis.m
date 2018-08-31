function [Imp, delta_z, p_delta_z] = BasicImpedanceAnalysis(filepath_v, filepath_i, duration, pre_on, pre_end, stim_on, stim_end, avg_window, Fmax)
% [filename_v pathname_v OK] = uigetfile('C:\Documents and Settings\elaine\My Documents\Impedance experiment data\*.dat', 'Select recorded voltage file');
% if (~OK) return; end
% filepath_v = [pathname_v, filename_v];
%
% [filename_i pathname_i OK] = uigetfile('C:\Documents and Settings\elaine\My Documents\Impedance experiment data\*.dat', 'Select injected current file');
% if (~OK) return; end
% filepath_i = [pathname_i, filename_i];
%
% duration = input('Trial duration in msec: ');
% stim_onset = input('whisker stimulus onset at: (in msec)');
% analysis_window = input('response duration in msec: ');
% avg_window = input('moving_avg window for impedance smoothing: ');
PLOT = false;
THRESH = 0;

stimuli = ReverseArray(GetStimCodes(filepath_v, duration))
%current and voltage files have the same set of stimuli%
%get unique set of stimuli%
n_stim = length(stimuli);
SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz

nScans = SAMPLERATE * (duration / 1000);
pre_on = SAMPLERATE*((pre_on)/1000);
pre_off = SAMPLERATE*((pre_end)/1000);
stim_on = SAMPLERATE*((stim_on)/1000);
stim_off = SAMPLERATE*((stim_end)/1000);

stim_window = stim_off - stim_on;
ps_window = pre_off - pre_on;

x = 0:(nScans-1);
recSize = (nScans + 1) * 4; %in bytes

disp(filepath_v);
disp(filepath_i);
fvid = fopen(filepath_v, 'r', 'b');
fiid = fopen(filepath_i, 'r', 'b');

headerSize_v = SkipHeader(fvid);
headerSize_i = SkipHeader(fiid);

nRecs_v = floor(GetNumberOfRecords(filepath_v, duration));
nRecs_i = floor(GetNumberOfRecords(filepath_i, duration));

if (nRecs_v~=nRecs_i)
    error('current and voltage recording have different number of trials');
end

nRecs = nRecs_v;
n_trials = ceil(nRecs/n_stim);

PSpre_i = zeros(n_stim, n_trials, ceil(ps_window/2));
PSpre_v = zeros(n_stim, n_trials, ceil(ps_window/2));
CSpre = zeros(n_stim, n_trials, ceil(ps_window/2));
pre_z = zeros(n_stim, n_trials, ceil(ps_window/2));

PSstim_i = zeros(n_stim, n_trials, ceil(ps_window/2));
PSstim_v = zeros(n_stim, n_trials, ceil(ps_window/2));
CSstim = zeros(n_stim, n_trials, ceil(ps_window/2));
stim_z = zeros(n_stim, n_trials, ceil(ps_window/2));

coh = zeros(n_stim, n_trials, ceil(ps_window/2));
stim_trial = zeros(1, n_stim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ppre_i = zeros(n_stim, n_trials, ceil(ps_window/2));
Ppre_v = zeros(n_stim, n_trials, ceil(ps_window/2));
Pstim_i = zeros(n_stim, n_trials, ceil(ps_window/2));
Pstim_v = zeros(n_stim, n_trials, ceil(ps_window/2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = figure;
ntrials = 0;
nskipped = 0;
while (~feof(fvid))
    stimulus_v = fread(fvid, 1, 'float32');
    stimulus_i = fread(fiid, 1, 'float32');
    %
    %
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;
    if (stimulus_v ~= stimulus_i) break; end;
    %
    stimulus = stimulus_v;
    %
    signal_v = fread(fvid, nScans, 'float32');
    signal_i = fread(fiid, nScans, 'float32');
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;

    prestim_v = signal_v(x>pre_on  & x<= pre_off );
    prestim_i = signal_i(x>pre_on  & x<= pre_off );

    stim_v = signal_v(x>stim_on & x<= stim_off);
    stim_i = signal_i(x>stim_on & x<= stim_off);
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;
    if PLOT
        figure(h);
        subplot(4,1,1);
        plot(prestim_i);
        ylabel('prestim input');
        subplot(4,1,2);
        plot(prestim_v);
        ylabel('prestim output');
        subplot(4,1,3);
        plot(stim_i);
        ylabel('stim input');
        subplot(4,1,4);
        plot(stim_v);
        ylabel('stim output');
    end

    ntrials = ntrials + 1;
    if max(prestim_v) > THRESH | max(stim_v) > THRESH
        nskipped = nskipped + 1;
        continue
    end
    
    for i = 1:n_stim

        if stimuli(i) == stimulus

            stim_trial(i)= stim_trial(i)+1;

            PS_i = PowerSpec(prestim_i);
            PS_v = PowerSpec(prestim_v);
                     
            PSpre_i(i, stim_trial(i), :) = PS_i;
            PSpre_v(i, stim_trial(i), :) = PS_v;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Ppre_i(i, stim_trial(i), :) = Spec(prestim_i);
            Ppre_v(i, stim_trial(i), :) = Spec(prestim_v);
            Pstim_i(i, stim_trial(i), :) = Spec(stim_i);
            Pstim_v(i, stim_trial(i), :) = Spec(stim_v);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            CrossIV = CrossSpec(prestim_i, prestim_v);
            CSpre(i, stim_trial(i), :) = CrossIV;
            pre_z(i, stim_trial(i), :) = abs(CrossIV) ./ PS_i;
            
            PS_i = PowerSpec(stim_i);
            PS_v = PowerSpec(stim_v);
                    
            PSstim_i(i, stim_trial(i), :) = PS_i;
            PSstim_v(i, stim_trial(i), :) = PS_v;
            CrossIV = CrossSpec(stim_i, stim_v);
            CSstim(i, stim_trial(i), :) = CrossIV;
            stim_z(i, stim_trial(i), :) = abs(CrossIV) ./ PS_i;
            
            coh(i, stim_trial(i), :) = sqrt(abs(CrossIV).^2 ./ (PS_i .* PS_v));            
        end;
    end;
end;
disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
disp(stim_trial);
fclose(fvid);
fclose(fiid);

freq = SAMPLERATE/2*linspace(0, 1, ceil(stim_window/2));
%freq = [0:stim_window/2-1] / ((stim_end - stim_onset) / 1000);

% %matlab's fft command calculates power for DC signal as well)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ppre_I = zeros(n_stim, ceil(stim_window/2));
Ppre_V = zeros(n_stim, ceil(stim_window/2));
Pstim_I = zeros(n_stim, ceil(stim_window/2));
Pstim_V = zeros(n_stim, ceil(stim_window/2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSpre_I = zeros(n_stim, ceil(stim_window/2));
PSpre_V = zeros(n_stim, ceil(stim_window/2));
PSstim_I = zeros(n_stim, ceil(stim_window/2));
PSstim_V = zeros(n_stim, ceil(stim_window/2));
CSpreMean = zeros(n_stim, ceil(stim_window/2));
CSstimMean = zeros(n_stim, ceil(stim_window/2));
pre_Z = zeros(n_stim, ceil(stim_window/2));
stim_Z = zeros(n_stim, ceil(stim_window/2));
Coh = zeros(n_stim, ceil(stim_window/2));

for i=1:n_stim  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Ppre_I(i, :) = MeanSpec(Ppre_i(i, 1:stim_trial(i), :));
    Ppre_V(i, :) = MeanSpec(Ppre_v(i, 1:stim_trial(i), :));
    Pstim_I(i, :) = MeanSpec(Pstim_i(i, 1:stim_trial(i), :));
    Pstim_V(i, :) = MeanSpec(Pstim_v(i, 1:stim_trial(i), :));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PSpre_I(i, :) = MeanSpec(PSpre_i(i, 1:stim_trial(i), :));
    PSpre_V(i, :) = MeanSpec(PSpre_v(i, 1:stim_trial(i), :));
    CSpreMean(i, :) = MeanSpec(CSpre(i, 1:stim_trial(i), :));
    
    PSstim_I(i, :) = MeanSpec(PSstim_i(i, 1:stim_trial(i), :));
    PSstim_V(i, :) = MeanSpec(PSstim_v(i, 1:stim_trial(i), :));
    CSstimMean(i, :) = MeanSpec(CSstim(i, 1:stim_trial(i), :));
    
    pre_Z(i, :) = MeanSpec(pre_z(i, 1:stim_trial(i), :));
    stim_Z(i, :) = MeanSpec(stim_z(i, 1:stim_trial(i), :));
    Coh(i, :) = MeanSpec(coh(i, 1:stim_trial(i), :));

    %      Imp(i, :)= [mean_imp(1:2),moving_average(mean_imp(3:end), avg_window)];
    %      ps_Z(i, :) = [mean_ps_z(1:2), moving_average(mean_ps_z(3:end), avg_window)];
    %      Coh(i, :)= [mean_coh(1:2), moving_average(mean_coh(3:end), avg_window)];
    %     %I_pspec(i, :)= [mean_If(1:2), moving_average(mean_If(3:end), avg_window)];
    %     %V_pspec(i, :)= [mean_Vf(1:2), moving_average(mean_Vf(3:end), avg_window)];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save Ppre_V.mat Ppre_V
% save PSpre_V.mat PSpre_V
% save Pstim_V.mat Pstim_V
% save PSstim_V.mat PSstim_V
% save freq.mat freq;
% % % 
% save Ppre_I.mat Ppre_I
% save PSpre_I.mat PSpre_I
% save PSstim_I.mat PSstim_I
% save Pstim_I.mat Pstim_I
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot power spectra
figure  ;
minpI = min(min(PSpre_I));
minpV = min(min(PSpre_V));
minsI = min(min(PSstim_I));
minsV = min(min(PSstim_V));
ymin = min([minpI minpV minsI minsV]);
maxpI = max(max(PSpre_I));
maxpV = max(max(PSpre_V));
maxsI = max(max(PSstim_I));
maxsV = max(max(PSstim_V));
ymax = max([maxpI maxpV maxsI maxsV]);

% plot(PSpre_I');
% hold on;
% plot(PSpre_V');
% return

subplot(2,2,1);
semilogy(freq, PSpre_I');
ylabel('pre-stimulus I power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,2);
semilogy(freq, PSpre_V');
ylabel('pre-stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,3);
semilogy(freq, PSstim_I');
ylabel('stimulus I power');
xlabel('freq (Hz)');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,4);
semilogy(freq, PSstim_V');
xlabel('freq (Hz)');
ylabel('stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

% Plot cross spectra
figure;
ymin = min(min(min(abs(CSpreMean))), min(min(abs(CSstimMean))));
ymax = max(max(max(abs(CSpreMean))), max(max(abs(CSstimMean))));

subplot(2,1,1);
semilogy(freq, abs(CSpreMean'));
ylabel('pre-stimulus I-V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,1,2);
semilogy(freq, abs(CSstimMean'));
xlabel('freq (Hz)');
ylabel('stimulus I-V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

% Plot pre-stim and stim impedances
z = figure;
ymin = min(min(min(pre_Z)), min(min(stim_Z)));
ymax = max(max(max(pre_Z)), max(max(stim_Z)));

figure(z);
subplot(2,1,1),
semilogy(freq, pre_Z);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
ylim([ymin ymax]);
ylabel('pre-stimulus Z (MOhm)');
grid on;

subplot(2,1,2),
semilogy(freq, stim_Z);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
xlabel('freq (Hz)');
ylim([ymin ymax]);
ylabel('stimulus Z (MOhm)');
grid on;

% Plot coherence
figure;
plot(freq, Coh);
xlabel('freq (Hz)');
ylabel('coherence');

% Plot change in impedance
dR = zeros(n_stim);
p_delta_z= zeros(n_stim, (stim_window)/2);
for i=1:n_stim
    dR(i) = 100 .* (pre_Z(i,1) - stim_Z(i,1)) ./ pre_Z(i,1);
    p_delta_z(i,:) = 100 .* (pre_Z(i,:) - stim_Z(i,:)) ./ pre_Z(i,:) ./ dR(i);
    p_delta_z(i,:) = moving_average(p_delta_z(i,:), avg_window);
end
% 
% noStimZ = p_delta_z(1,:);
% for i=1:n_stim
%     p_delta_z(i,:) = p_delta_z(i,:) - noStimZ;
% end

% noStimZ = p_delta_z(3,:);
% for i=1:n_stim
%     p_delta_z(i,:) = p_delta_z(i,:) - noStimZ;
% end

change_in_z=figure;
figure(change_in_z);
% subplot(2,1,1);
% plot(freq, delta_z(1, :), 'LineWidth', 3);
% hold on;
% plot(freq, delta_z(2:n_stim, :));
% ylabel('net change in Z');
% legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
% xlim([0 Fmax]);
% grid on;
% 
% subplot(2,1,2);
disp(size(p_delta_z(2:n_stim,:)));
plot(freq, p_delta_z(1, :), 'LineWidth', 3);
if n_stim > 1
    hold on;
    plot(freq, p_delta_z(2:n_stim, :));
end
xlabel('freq (Hz)');
ylabel('delta Z');
legend('0', '45', '90', '135', '180', '225', '270', '315'),
%legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
xlim([0 Fmax]);
grid on;
%%%%%%%%%%%%%%%%
normalized_change_in_z=figure;
figure(normalized_change_in_z);

[peak, j] = min(min(p_delta_z(:, 1:100)));
%[minimum, l] = min(peak);
%min_stim = j(l)
for i = 1: n_stim
    n_p_delta_z (i, :) = p_delta_z(i, :)/abs(min(p_delta_z(i, 1:100)));
end

plot(freq, n_p_delta_z(1, :), 'LineWidth', 3);
if n_stim > 1
    hold on;
     plot(freq, n_p_delta_z(2:n_stim, :));
end
xlabel('freq (Hz)');
ylabel('normalized delta Z');
%legend('0', '45', '90', '135', '180', '225', '270', '315'),
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
xlim([0 1000]);
grid on;
% Calculate impedance from averages rather than on a per-trial basis
% pZ = zeros(n_stim, (stim_window)/2);
% sZ = zeros(n_stim, (stim_window)/2);
% dZ = zeros(n_stim, (stim_window)/2);
% for i=1:n_stim
%     pZ(i,:) = abs(CSpreMean(i, :)) ./ PSpre_I(i, :);
%     sZ(i,:) = abs(CSstimMean(i, :)) ./ PSstim_I(i, :);
%     dZ(i,:) = 100 * (sZ(i,:) - pZ(i,:)) ./ pZ(i,1);
% end
% 
% figure
% plot(freq, dZ);
% xlim([0 Fmax]);



