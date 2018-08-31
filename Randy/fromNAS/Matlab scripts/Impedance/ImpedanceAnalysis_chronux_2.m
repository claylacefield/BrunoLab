function [Imp, delta_z, p_delta_z] = ImpedanceAnalysis_chornux_2(filepath_ws, filepath_v, filepath_i, ws_duration, ws_pre_on, ws_pre_end, ws_stim_on, ws_stim_end, duration, pre_on, pre_end, stim_on, stim_end, Fmax, NW, K, Fs, fpass, pad, trialave,AP_thresh, AP_on_off)
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

THRESH = AP_thresh/100%-0.1;
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
params.trialave = trialave;
params.tapers = [NW K];

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
    if AP_on_off
    if max(prestim_ws) > THRESH | max(stim_ws) > THRESH
        ws_nskipped = ws_nskipped + 1;
        continue
    end
    end
    i = find(ws_stimuli == ws_stimulus);

    ws_stim_trial(i)= ws_stim_trial(i)+1;

    pre_ws(:, ws_stim_trial(i), i) = prestim_ws;
    Stim_ws(:, ws_stim_trial(i), i) = stim_ws;
    

end;

% [psp] = PolarPlots
% for i = 1:ws_n_stim
%     data = squeeze(pre_ws(:,1:ws_stim_trial(i), i));
%     [S_pre,f]=mtspectrumc(data,params);
%     S_pre_ws(:, 1:ws_stim_trial(i), i) = S_pre;
%     freq_ws = f;
%
%     data2 = squeeze(Stim_ws(:,1:ws_stim_trial(i), i));
%     [S_stim,f]=mtspectrumc(data2,params);
%     S_stim_ws(:,1:ws_stim_trial(i), i) = S_stim;
%
% end;
%
% for i = 1:ws_n_stim
%     prestim_ws_mean (:,i) = squeeze(mean(pre_ws(:, 1:ws_stim_trial(i), i ), 2));
%     stim_ws_mean (:,i) = squeeze(mean(Stim_ws(:, 1:ws_stim_trial(i), i ), 2));
%
%     Spre_ws_mean(:, i) = squeeze(mean(S_pre_ws(:, 1:ws_stim_trial(i), i ), 2));
%     pre_ws_var(:, i) = squeeze(var(S_pre_ws(:, 1:ws_stim_trial(i), i ), 0, 2));
%
%     Sstim_ws_mean(:, i) = squeeze(mean(S_stim_ws(:, 1:ws_stim_trial(i), i ), 2));
%     stim_ws_var(:, i) = squeeze(var(S_stim_ws(:, 1:ws_stim_trial(i), i ), 0, 2));
%
% end






 
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



ntrials = 0;
nskipped = 0;
figure;
hold on;
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
    %stim_v = stim_v - mean(stim_v);
    
    plot(abs(fft(stim_v)));
    
    stim_i = signal_i(x>stim_on & x<= stim_off);
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;
    if PLOT
        h = figure;
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
        set(gcf, 'Name', 'voltage trace');
        plotedit('ON');
    end

    ntrials = ntrials + 1;
    if AP_on_off
        if max(prestim_v) > THRESH | max(stim_v) > THRESH
            nskipped = nskipped + 1;
            continue
        end
    end
    i = find(stimuli == stimulus);

    stim_trial(i)= stim_trial(i)+1;

    pre_i(:, stim_trial(i), i) = prestim_i;
    pre_v(:, stim_trial(i), i) = prestim_v;
    Stim_i(:, stim_trial(i), i) = stim_i;
    Stim_v(:, stim_trial(i), i) = stim_v;
end;
hold off

for i = 1:n_stim;
%     data1 = squeeze(pre_i(:,1:stim_trial(i), i));
%     data2 = squeeze(pre_v(:,1:stim_trial(i), i));
% 
%     [C_pre, phi, S12_pre,S1_pre,S2_pre,f]= coherencyc(data1,data2,params);
%     CSpre(:,  i) = S12_pre;
%     Spre_I(:, i) = S1_pre;
%     Spre_V(:, i) = S2_pre;
%     freq = f;
%     Coh_pre(:, i) = C_pre;
%     pre_z = abs(S12_pre./S1_pre);
%     pre_Z(:,i) = pre_z;

    data3 = squeeze(Stim_i(:,1:stim_trial(i),i));
    data4 = squeeze(Stim_v(:,1:stim_trial(i),i));
    [C_stim,phi_stim,S12_stim,S1_stim,S2_stim,f]= coherencyc(data3,data4,params);
    CSstim(:, i) = S12_stim;
    Sstim_I(:, i) = S1_stim;
    Sstim_V(:, i) = S2_stim;
    freq = f;
    Coh_stim(:,i) = C_stim;
    stim_z = abs(S12_stim./S1_stim);
    stim_Z(:,i) = stim_z;
    
    %     delta_z (:,1:stim_trial(i),i) =  stim_z - pre_z;
    %     p_delta_z (:, 1:stim_trial(i), i) = 100.*(stim_z - pre_z)./pre_z;
    %
end;
%%%%%%%

% for i = 1:n_stim
%     if i == 1
%         data1 = squeeze(pre_ws(:,1:ws_stim_trial(i), i));
%         data2 = squeeze(Stim_i(:,1:ws_stim_trial(i),i));
%         [C, phi, S12, S1, S2]= coherencyc(data1, data2, params);
%         Cohi_ws(:, i) = C;
%         CSi_ws(:, i) = S12;
%         Zi_ws(:, i) = abs(S12./S2);
%         Zcs_ws(:, i)=stim_Z(:,i)./S1;
%         S_ws (:,i) = S1;
% %         Z_PSP_amp (:,i) = stim_Z(:,i);
%     end
%     if i >1
%     data1 = squeeze(Stim_ws(:,1:ws_stim_trial(i-1), i-1));
%     data2 = squeeze(Stim_i(:,1:ws_stim_trial(i-1),i));
%     [C, phi, S12, S1, S2, f]= coherencyc(data1, data2, params);
%     Cohi_ws(:, i) = C;
%     CSi_ws(:, i) = S12;
%     Zi_ws(:, i) = abs(S12./S2);
%     Zcs_ws(:, i)=stim_Z(:,i)./S1;
%     S_ws (:,i) = S1;
% %     Z_PSP_amp (:,i) = stim_Z(:,i)/psp(i-1);
%     freq = f;
%     
%     end
% end

disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
disp(stim_trial);
fclose(fvid);
fclose(fiid);
for i = 1:n_stim
    prestim_v_mean (:,i) = squeeze(mean(pre_v(:, 1:stim_trial(i), i ), 2));
    stim_v_mean (:,i) = squeeze(mean(Stim_v(:, 1:stim_trial(i), i ), 2));
end
% figure;
% minpre_v = min(min(prestim_v_mean));
% maxpre_v = max(max(prestim_v_mean));

% for i=1:n_stim
%     subplot(9,1,i);
%     plot(prestim_v_mean(:,i));
%     ylim([minpre_v maxpre_v]);
%     ylabel('prestim voltage');
%     title(stimuli(i));
% end
% set(gcf, 'Name', 'mean prestimulus voltage vs time');
% plotedit('ON');

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
set(gcf, 'Name', 'mean voltage vs time');
plotedit('ON');


figure;
% subplot(3,1,1);
% %Coh_pre1 = squeeze(Coh_pre(:,:,1));
% plot(freq, squeeze(mean(Cohpre_mean, 2)));
% xlim([0 Fmax]);
% ylabel('pre-stimulus coherence');
% subplot(3,1,2);
%Coh_stim2 = squeeze(Coh_stim(:,:,2));
plot(freq, Coh_stim);
xlim([0 Fmax]);
ylabel('stimulus coherence');
set(gcf, 'Name', 'Coherence during stimulus');
plotedit('ON');

% 
% subplot(3,1,3);
% for i = 1:n_stim
%     Cohstim_mean(:,i) = Cohstim_mean(:, i) - squeeze(mean(Cohpre_mean, 2));
% end
% plot(freq, Cohstim_mean);
% xlim([0 Fmax]);


figure  ;
% minpI = min(min(Spre_I));
% minpV = min(min(Spre_V));
minsI = min(min(Sstim_I));
minsV = min(min(Sstim_V));
ymin = min([minsI minsV]);
% maxpI = max(max(SpreI_mean));
% maxpV = max(max(SpreV_mean));
maxsI = max(max(Sstim_I));
maxsV = max(max(Sstim_V));
ymax = max([maxsI maxsV]);

subplot(2,1,1);
plot(freq, Sstim_I);
ylabel('stimulus I power');
xlabel('freq (Hz)');
xlim([0 Fmax]);
ylim([ymin ymax]);

subplot(2,1,2);
plot(freq, Sstim_V);
xlabel('freq (Hz)');
ylabel('stimulus V power');
xlim([0 Fmax]);
ylim([ymin ymax]);
set(gcf, 'Name', 'I & V Power Spectrum');
plotedit('ON');

% % Plot cross spectra
figure;
% 
ymin = min(min(abs(CSstim)));
ymax = max(max(abs(CSstim)));
% 
% subplot(2,1,1);
% semilogy(freq, abs(CSpre_mean));
% ylabel('pre-stimulus I-V power');
% xlim([0 Fmax]);
% ylim([ymin ymax]);

% subplot(2,1,1);
semilogy(freq, abs(CSstim));
xlabel('freq (Hz)');
ylabel('stimulus I-V power');
xlim([0 Fmax]);
ylim([ymin ymax]);
set(gcf, 'Name', 'IV Cross Spectrum');
plotedit('ON');

% Plot pre-stim and stim impedances

%  ymin = min(min(min(preZ_mean)), min(min(stimZ_mean)));
%  ymax = max(max(max(preZ_mean)), max(max(stimZ_mean)));
% % ws = figure;
% % figure(ws);
% % semilogy(freq, S_ws);
% % legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
% % xlim([0 Fmax]);
% % % ylim([ymin ymax]);
% % ylabel('whisker stim power spec');
% % grid on;
% % set(gcf, 'Name', 'V(whisker) Power Spectrum');
% % plotedit('ON');

z = figure;
figure(z);
subplot(2,2,1),
semilogy(freq, stim_Z);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
% ylim([ymin ymax]);
ylabel('stimulus Z (MOhm)');
grid on;
 
subplot(2,2,2),
semilogy(freq, Zi_ws);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
xlabel('freq (Hz)');
% ylim([ymin ymax]);
ylabel('CS(whisker stim & current)/S(current)');
grid on;

 
subplot(2,2,3),
semilogy(freq, Zcs_ws);
legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
xlim([0 Fmax]);
xlabel('freq (Hz)');
% ylim([ymin ymax]);
ylabel('impedance normalized by Swhisker');
grid on;

% 
% subplot(2,2,4),
% semilogy(freq, Z_PSP_amp);
% legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
% xlim([0 Fmax]);
% xlabel('freq (Hz)');
% % ylim([ymin ymax]);
% ylabel('impedance normalized by whisker stim PSP');
% grid on; 
set(gcf, 'Name', 'Impedance');
plotedit('ON');

% for i = 1:n_stim
% delta_Z(:, i) = Zcs_ws(:, i)-Zcs_ws(:,1);
% end

% k = max(psp)
% j = find(k ==psp)+1;
% for i = 1:n_stim
%     ratio(:,i) = stim_Z(:,i)./stim_Z(:,j);    
% end
% 
% figure;
% plot(freq, ratio);
% xlim([0 Fmax]);
% xlabel('freq (Hz)');
% ylabel('ratio of Z(all directions) to Z(preferred direction)')
% legend('no stim','0', '45', '90', '135', '180', '225', '270', '315');
% set(gcf, 'Name', 'Z(non-pref)/Z(pref)');
% plotedit('ON');



