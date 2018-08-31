function [Imp, delta_z, p_delta_z] = ImpedanceAnalysis_chornux_2(filepath_ws, filepath_v, filepath_i, ws_duration, ws_pre_on, ws_pre_end, ws_stim_on, ws_stim_end, duration, pre_on, pre_end, stim_on, stim_end, Fmax, NW, K, Fs, fpass, pad, trialave)
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
THRESH = -0.1;
stimuli = ReverseArray(GetStimCodes(filepath_v, duration))
%current and voltage files have the same set of stimuli%
%get unique set of stimuli%
n_stim = length(stimuli);
SCALINGFACTOR = 100;
SAMPLERATE = Fs; % in Hz
%get power spectrum of the whisker stimuli alone voltage recordings%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.pad = pad;
params.Fs = SAMPLERATE;
params.fpass = [1 fpass];
params.trialave = 0;
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
%%%%%%%%%%
disp(filepath_ws)
disp(ws_duration)
ws_stimuli = ReverseArray(GetStimCodes(filepath_ws, ws_duration))
ws_n_stim = length(ws_stimuli);

ws_nScans = SAMPLERATE * (ws_duration / 1000);
ws_pre_on = SAMPLERATE*((ws_pre_on)/1000);
ws_pre_off = SAMPLERATE*((ws_pre_end)/1000);
ws_stim_on = SAMPLERATE*((ws_stim_on)/1000);
ws_stim_off = SAMPLERATE*((ws_stim_end)/1000);
ws_stim_window = ws_stim_off - ws_stim_on;
ws_ps_window = ws_pre_off - ws_pre_on;

ws_x = 0:(ws_nScans-1);
ws_recSize = (ws_nScans + 1)*4;

%%%%%%%%%%
disp(filepath_ws);
fwsid = fopen(filepath_ws, 'r', 'b');
headerSize_ws = SkipHeader(fwsid);
ws_nRecs = floor(GetNumberOfRecords(filepath_ws, ws_duration));
ws_n_trials = ceil(ws_nRecs/ws_n_stim);

pre_ws = zeros(ws_ps_window, ws_n_trials, ws_n_stim);
Stim_ws = zeros(ws_stim_window, ws_n_trials, ws_n_stim);

ws_stim_trial = zeros(1, ws_n_stim);
ws_ntrials = 0;
ws_nskipped = 0;

while (~feof(fwsid))
    ws_stimulus = fread(fwsid, 1, 'float32');
    if(feof(fwsid)) break; end;
    signal_ws = fread(fwsid, ws_nScans, 'float32');
    if(feof(fwsid)) break; end;

    prestim_ws = signal_ws(ws_x>ws_pre_on  & ws_x<= ws_pre_off );
    stim_ws = signal_ws(ws_x>ws_stim_on & ws_x<= ws_stim_off);
    if(feof(fwsid)) break; end;

    ws_ntrials = ws_ntrials + 1;
    if max(prestim_ws) > THRESH | max(stim_ws) > THRESH
        ws_nskipped = ws_nskipped + 1;
        continue
    end

    i = find(ws_stimuli == ws_stimulus);

    ws_stim_trial(i)= ws_stim_trial(i)+1;

    pre_ws(:, ws_stim_trial(i), i) = prestim_ws;
    Stim_ws(:, ws_stim_trial(i), i) = stim_ws;

end;

for i = 1:ws_n_stim
    data = squeeze(pre_ws(:,1:ws_stim_trial(i), i));
    [S_pre,f]=mtspectrumc(data,params);
    S_pre_ws(:, 1:ws_stim_trial(i), i) = S_pre;
    freq_ws = f;

    data2 = squeeze(Stim_ws(:,1:ws_stim_trial(i), i));
    [S_stim,f]=mtspectrumc(data2,params);
    S_stim_ws(:,1:ws_stim_trial(i), i) = S_stim;

end;

for i = 1:ws_n_stim
    prestim_ws_mean (:,i) = squeeze(mean(pre_ws(:, 1:ws_stim_trial(i), i ), 2));
    stim_ws_mean (:,i) = squeeze(mean(Stim_ws(:, 1:ws_stim_trial(i), i ), 2));

    Spre_ws_mean(:, i) = squeeze(mean(S_pre_ws(:, 1:ws_stim_trial(i), i ), 2));
    pre_ws_var(:, i) = squeeze(var(S_pre_ws(:, 1:ws_stim_trial(i), i ), 0, 2));

    Sstim_ws_mean(:, i) = squeeze(mean(S_stim_ws(:, 1:ws_stim_trial(i), i ), 2));
    stim_ws_var(:, i) = squeeze(var(S_stim_ws(:, 1:ws_stim_trial(i), i ), 0, 2));

end







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
    pre_v(:, stim_trial(i), i) = prestim_v;% - mean(prestim_v);
    Stim_i(:, stim_trial(i), i) = stim_i;
    Stim_v(:, stim_trial(i), i) = stim_v;% - mean(stim_v);
end;


for i = 1:n_stim;
    data1 = squeeze(pre_i(:,1:stim_trial(i), i));
    data2 = squeeze(pre_v(:,1:stim_trial(i), i));

    [C_pre, phi, S12_pre,S1_pre,S2_pre,f]= coherencyc(data1,data2,params);
    CSpre(:, 1:stim_trial(i), i) = S12_pre;
    Spre_I(:,1:stim_trial(i), i) = S1_pre;
    Spre_V(:,1:stim_trial(i), i) = S2_pre;
    freq = f;
    Coh_pre(:,1:stim_trial(i), i) = C_pre;
    pre_z = abs(S12_pre)./S1_pre;
    pre_Z(:,1:stim_trial(i),i) = pre_z;

    data3 = squeeze(Stim_i(:,1:stim_trial(i),i));
    data4 = squeeze(Stim_v(:,1:stim_trial(i),i));
    [C_stim,phi_stim,S12_stim,S1_stim,S2_stim,f]= coherencyc(data3,data4,params);
    CSstim(:,1:stim_trial(i), i) = S12_stim;
    Sstim_I(:,1:stim_trial(i), i) = S1_stim;
    Sstim_V(:,1:stim_trial(i), i) = S2_stim;
    freq = f;
    Coh_stim(:,1:stim_trial(i),i) = C_stim;
    stim_z = abs(S12_stim)./S1_stim;
    stim_Z(:,1:stim_trial(i),i) = stim_z;
    delta_z (:,1:stim_trial(i),i) =  stim_z - pre_z;
    p_delta_z (:, 1:stim_trial(i), i) = 100.*(stim_z - pre_z)./pre_z;
    
    
end;
%%%%%%%
for i = 1:n_stim
    prestim_v_mean (:,i) = squeeze(mean(pre_v(:, 1:stim_trial(i), i ), 2));
    stim_v_mean (:,i) = squeeze(mean(Stim_v(:, 1:stim_trial(i), i ), 2));

    CSpre_mean(:, i) = squeeze(mean(CSpre(:, 1:stim_trial(i), i ), 2));
    SpreI_mean(:, i) = squeeze(mean(Spre_I(:, 1:stim_trial(i), i ), 2));
    SpreV_mean(:, i) = squeeze(mean(Spre_V(:, 1:stim_trial(i), i ), 2));
    Cohpre_mean(:, i) = squeeze(mean(Coh_pre(:, 1:stim_trial(i), i ), 2));
    preZ_mean(:, i) = squeeze(mean(pre_Z(:, 1:stim_trial(i), i ),2));
    preZ_var(:, i) = squeeze(var(pre_Z(:, 1:stim_trial(i), i ), 0, 2));

    CSstim_mean(:, i) = squeeze(mean(CSstim(:, 1:stim_trial(i), i ), 2));
    SstimI_mean(:, i) = squeeze(mean(Sstim_I(:, 1:stim_trial(i), i ), 2));
    SstimV_mean(:, i) = squeeze(mean(Sstim_V(:, 1:stim_trial(i), i ), 2));
    Cohstim_mean(:, i) = squeeze(mean(Coh_stim(:, 1:stim_trial(i), i ), 2));
    stimZ_mean(:, i) = squeeze(mean(stim_Z(:, 1:stim_trial(i), i ),2));
    stimZ_var(:, i) = squeeze(var(stim_Z(:, 1:stim_trial(i), i ), 0, 2));

    delta_Z_mean(:, i) = squeeze(mean(delta_z(:, 1:stim_trial(i), i ), 2));
    pDeltaZ_mean(:, i) = squeeze(mean(p_delta_z(:, 1:stim_trial(i), i ), 2));
    %pDeltaZ_var = squeeze(var(p_delta_z, 0, 2));
end


disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
disp(stim_trial);
fclose(fvid);
fclose(fiid);


figure;
minpre_v = min(min(prestim_v_mean));
maxpre_v = max(max(prestim_v_mean));

for i=1:n_stim
    subplot(9,1,i);
    plot(prestim_v_mean(:,i));
    ylim([minpre_v maxpre_v]);
    ylabel('prestim voltage');
    title(stimuli(i));
end

figure;
minstim_v = min(min(stim_v_mean));
maxstim_v = max(max(stim_v_mean));

for i=1:n_stim
    subplot(9,1,i);
    plot(stim_v_mean(:,i));
    ylim([minstim_v maxstim_v]);
    ylabel('stim voltage');
    title(stimuli(i));
end


figure;
subplot(3,1,1);
%Coh_pre1 = squeeze(Coh_pre(:,:,1));
plot(freq, squeeze(mean(Cohpre_mean, 2)));
xlim([0 Fmax]);
ylabel('pre-stimulus coherence');
subplot(3,1,2);
%Coh_stim2 = squeeze(Coh_stim(:,:,2));
plot(freq, Cohstim_mean);
xlim([0 Fmax]);
ylabel('stimulus coherence');

subplot(3,1,3);
for i = 1:n_stim
    Cohstim_mean(:,i) = Cohstim_mean(:, i) - squeeze(mean(Cohpre_mean, 2));
end
plot(freq, Cohstim_mean);
xlim([0 Fmax]);


figure  ;
minpI = min(min(SpreI_mean));
minpV = min(min(SpreV_mean));
minsI = min(min(SstimI_mean));
minsV = min(min(SstimV_mean));
ymin = min([minpI minpV minsI minsV]);
maxpI = max(max(SpreI_mean));
maxpV = max(max(SpreV_mean));
maxsI = max(max(SstimI_mean));
maxsV = max(max(SstimV_mean));
ymax = max([maxpI maxpV maxsI maxsV]);

subplot(2,2,1);
semilogy(freq, SpreI_mean);
ylabel('pre-stimulus I power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,2);
semilogy(freq, SpreV_mean);
ylabel('pre-stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,3);
semilogy(freq, SstimI_mean);
ylabel('stimulus I power');
xlabel('freq (Hz)');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,2,4);
semilogy(freq, SstimV_mean);
xlabel('freq (Hz)');
ylabel('stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

% % Plot cross spectra
figure;

ymin = min(min(min(abs(CSpre_mean))), min(min(abs(CSstim_mean))));
ymax = max(max(max(abs(CSpre_mean))), max(max(abs(CSstim_mean))));

subplot(2,1,1);
semilogy(freq, abs(CSpre_mean));
ylabel('pre-stimulus I-V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,1,2);
semilogy(freq, abs(CSstim_mean));
xlabel('freq (Hz)');
ylabel('stimulus I-V power');
xlim([0 Fmax]);
ylim([ymin ymax]);

% Plot pre-stim and stim impedances
z = figure;
ymin = min(min(min(preZ_mean)), min(min(stimZ_mean)));
ymax = max(max(max(preZ_mean)), max(max(stimZ_mean)));

figure(z);
subplot(2,1,1),
semilogy(freq, preZ_mean);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
ylim([ymin ymax]);
ylabel('pre-stimulus Z (MOhm)');
grid on;

subplot(2,1,2),
semilogy(freq, stimZ_mean);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
xlabel('freq (Hz)');
ylim([ymin ymax]);
ylabel('stimulus Z (MOhm)');
grid on;
 

var_z = figure;
ymin = min(min(min(preZ_var)), min(min(stimZ_var)));
ymax = max(max(max(preZ_var)), max(max(stimZ_var)));

figure(var_z);
subplot(2,1,1),
semilogy(freq, preZ_var);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
ylim([ymin ymax]);
ylabel('variance of pre-stimulus Z (MOhm)');
grid on;

subplot(2,1,2),
semilogy(freq, stimZ_var);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
xlabel('freq (Hz)');
ylim([ymin ymax]);
ylabel('variance of stimulus Z (MOhm)');
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
% for i=1:n_stim
% %    dR(i) = 100 .* (pre_Z(1,i) - stim_Z(1,i)) ./ pre_Z(1,i);
%     p_delta_z(:, i) = 100 .* (stim_Z(:, i) - pre_Z(:, i)) ./ pre_Z(:, i); %./ dR(i);
% %    p_delta_z(:, i) = moving_average(p_delta_z(:, i), avg_window);
% end
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
disp(size(pDeltaZ_mean(:, 2:n_stim)));
plot(freq, pDeltaZ_mean(:, 1), 'LineWidth', 3);
if n_stim > 1
    hold on;
    plot(freq, pDeltaZ_mean(:, 2:n_stim));
end
xlabel('freq (Hz)');
ylabel('delta Z');
%legend('0', '45', '90', '135', '180', '225', '270', '315'),
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
xlim([0 Fmax]);
grid on;

pDeltaZ_ws_mean = 
figure;
plot(freq, pDeltaZ_ws_mean);
xlabel('freq (Hz)');
ylabel('delta Z - V_ws');
%legend('0', '45', '90', '135', '180', '225', '270', '315'),
legend('0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
grid on;