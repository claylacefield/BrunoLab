function [Imp, delta_z, p_delta_z] = ImpedanceAnalysis_chornux(filepath_v, filepath_i, duration, pre_on, pre_end, stim_on, stim_end, Fmax, NW, K, Fs, fpass, pad, trialave)
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
SAMPLERATE = Fs; % in Hz

params.pad = pad;
params.Fs = SAMPLERATE;
params.fpass = [1 fpass];
params.trialave = trialave;
params.tapers = [NW K]

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

pre_i = zeros(ps_window, n_trials, n_stim);
pre_v = zeros(ps_window, n_trials, n_stim);
Stim_i = zeros(ps_window, n_trials, n_stim);
Stim_v = zeros(ps_window, n_trials, n_stim);

stim_trial = zeros(1, n_stim);


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
    
    i = find(stimuli == stimulus);

    stim_trial(i)= stim_trial(i)+1;

    pre_i(:, stim_trial(i), i) = prestim_i;
    pre_v(:, stim_trial(i), i) = prestim_v; % - mean(prestim_v);
    Stim_i(:, stim_trial(i), i) = stim_i;
    Stim_v(:, stim_trial(i), i) = stim_v;% - mean(stim_v);
end;


for i = 1:n_stim;
    data1 = squeeze(pre_i(:,1:stim_trial(i), i));
    data2 = squeeze(pre_v(:,1:stim_trial(i), i));
    
    [C_pre, phi, S12_pre,S1_pre,S2_pre,f]= coherencyc(data1,data2,params);
    CSpre(:, i) = S12_pre;
    Spre_I(:, i) = S1_pre;
    Spre_V(:, i) = S2_pre;
    freq = f;
    Coh_pre(:,i) = C_pre;
    pre_Z(:,i) = abs(S12_pre)./S1_pre;
    
    data3 = squeeze(Stim_i(:,1:stim_trial(i),i));
    data4 = squeeze(Stim_v(:,1:stim_trial(i),i));
    [C_stim,phi_stim,S12_stim,S1_stim,S2_stim,f]= coherencyc(data3,data4,params);
    CSstim(:, i) = S12_stim;
    Sstim_I(:, i) = S1_stim;
    Sstim_V(:, i) = S2_stim;
    freq = f;
    Coh_stim(:,i) = C_stim;
    stim_Z(:,i) = abs(S12_stim)./S1_stim;
end;

disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
disp(stim_trial);
fclose(fvid);
fclose(fiid);


figure;
subplot(2,1,1);
plot(freq, Coh_pre);
xlim([0 Fmax]);
ylabel('pre-stimulus coherence');
subplot(2,1,2);
plot(freq, Coh_stim);
xlim([0 Fmax]);
ylabel('stimulus coherence');
figure  ;

minpI = min(min(Spre_I));
minpV = min(min(Spre_V));
minsI = min(min(Sstim_I));
minsV = min(min(Sstim_V));
ymin = min([minpI minpV minsI minsV]);
maxpI = max(max(Spre_I));
maxpV = max(max(Spre_V));
maxsI = max(max(Sstim_I));
maxsV = max(max(Sstim_V));
ymax = max([maxpI maxpV maxsI maxsV]);

subplot(2,2,1);
semilogy(freq, Spre_I');
ylabel('pre-stimulus I power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,2);
semilogy(freq, Spre_V');
ylabel('pre-stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,3);
semilogy(freq, Sstim_I');
ylabel('stimulus I power');
xlabel('freq (Hz)');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,4);
semilogy(freq, Sstim_V');
xlabel('freq (Hz)');
ylabel('stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

% % Plot cross spectra
figure;
ymin = min(min(min(abs(CSpre))), min(min(abs(CSstim))));
ymax = max(max(max(abs(CSpre))), max(max(abs(CSstim))));

subplot(2,1,1);
semilogy(freq, abs(CSpre));
ylabel('pre-stimulus I-V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,1,2);
semilogy(freq, abs(CSstim));
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

% % Plot coherence
% figure;
% plot(freq, Coh);
% xlabel('freq (Hz)');
% ylabel('coherence');
% 
% Plot change in impedance
dR = zeros(n_stim);
%p_delta_z= zeros(n_stim, (stim_window)/2);
for i=1:n_stim
%    dR(i) = 100 .* (pre_Z(1,i) - stim_Z(1,i)) ./ pre_Z(1,i);
    p_delta_z(:, i) = 100 .* (stim_Z(:, i) - pre_Z(:, i)) ./ pre_Z(:, i); %./ dR(i);
%    p_delta_z(:, i) = moving_average(p_delta_z(:, i), avg_window);
end
% 
% noStimZ = p_delta_z(:, 1);
% for i=1:n_stim
%     p_delta_z(:, i) = p_delta_z(:, i) - noStimZ;
% end
% 
% % noStimZ = p_delta_z(3,:);
% % for i=1:n_stim
% %     p_delta_z(i,:) = p_delta_z(i,:) - noStimZ;
% % end
% 
change_in_z=figure;
% figure(change_in_z);
% % subplot(2,1,1);
% % plot(freq, delta_z(1, :), 'LineWidth', 3);
% % hold on;
% % plot(freq, delta_z(2:n_stim, :));
% % ylabel('net change in Z');
% % legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
% % xlim([0 Fmax]);
% % grid on;
% % 
% % subplot(2,1,2);
disp(size(p_delta_z(:, 2:n_stim)));
plot(freq, p_delta_z(:, 1), 'LineWidth', 3);
if n_stim > 1
    hold on;
    plot(freq, p_delta_z(:, 2:n_stim));
end
xlabel('freq (Hz)');
ylabel('delta Z');
%legend('0', '45', '90', '135', '180', '225', '270', '315'),
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
xlim([0 Fmax]);
grid on;
% %%%%%%%%%%%%%%%%
% normalized_change_in_z=figure;
% figure(normalized_change_in_z);
% 
% [peak, j] = min(min(p_delta_z(:, 1:100)));
% %[minimum, l] = min(peak);
% %min_stim = j(l)
% for i = 1: n_stim
%     n_p_delta_z (i, :) = p_delta_z(i, :)/abs(min(p_delta_z(i, 1:100)));
% end
% 
% plot(freq, n_p_delta_z(1, :), 'LineWidth', 3);
% if n_stim > 1
%     hold on;
%      plot(freq, n_p_delta_z(2:n_stim, :));
% end
% xlabel('freq (Hz)');
% ylabel('normalized delta Z');
% %legend('0', '45', '90', '135', '180', '225', '270', '315'),
% legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
% xlim([0 1000]);
% grid on;
% % Calculate impedance from averages rather than on a per-trial basis
% % pZ = zeros(n_stim, (stim_window)/2);
% % sZ = zeros(n_stim, (stim_window)/2);
% % dZ = zeros(n_stim, (stim_window)/2);
% % for i=1:n_stim
% %     pZ(i,:) = abs(CSpreMean(i, :)) ./ PSpre_I(i, :);
% %     sZ(i,:) = abs(CSstimMean(i, :)) ./ PSstim_I(i, :);
% %     dZ(i,:) = 100 * (sZ(i,:) - pZ(i,:)) ./ pZ(i,1);
% % end
% % 
% % figure
% % plot(freq, dZ);
% % xlim([0 Fmax]);
% 
% 
% 
