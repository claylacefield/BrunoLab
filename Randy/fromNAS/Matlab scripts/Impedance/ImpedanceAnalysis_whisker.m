function[Imp, delta_z, p_delta_z] = ImpedanceAnalysis_whisker(ws_params, wn_params, params, AP_thresh, AP_on_off, chronux_on_off);

PLOT = false;
THRESH = AP_thresh;
stimuli = ReverseArray(GetStimCodes(wn_params.filepath_v, wn_params.duration))
n_stim = length(stimuli);
for i = 1:n_stim
    wn_code = stimuli(i);
    angle(i) = StimCodeToDegrees(wn_code);
end

SCALINGFACTOR = 100;
SAMPLERATE = params.Fs; % in Hz

nScans = SAMPLERATE * (wn_params.duration / 1000);
pre_on = SAMPLERATE*((wn_params.ps_on)/1000);
pre_off = SAMPLERATE*((wn_params.ps_end)/1000);
stim_on = SAMPLERATE*((wn_params.stim_on)/1000);
stim_off = SAMPLERATE*((wn_params.stim_end)/1000);
stim_window = stim_off - stim_on;
ps_window = pre_off - pre_on;

x = 0:(nScans-1);
recSize = (nScans + 1) * 4; %in bytes

disp(wn_params.filepath_v);
disp(wn_params.filepath_i);

fvid = fopen(wn_params.filepath_v, 'r', 'b');
fiid = fopen(wn_params.filepath_i, 'r', 'b');

headerSize_v = SkipHeader(fvid);
headerSize_i = SkipHeader(fiid);

nRecs_v = floor(GetNumberOfRecords(wn_params.filepath_v, wn_params.duration));
nRecs_i = floor(GetNumberOfRecords(wn_params.filepath_i, wn_params.duration));

if (nRecs_v~=nRecs_i)
    error('current and voltage recording have different number of trials');
end

nRecs = nRecs_v;
n_trials = ceil(nRecs/n_stim);

pre_i = zeros(ps_window, n_trials, n_stim);
pre_v = zeros(ps_window, n_trials, n_stim);
Stim_i = zeros(stim_window, n_trials, n_stim);
Stim_v = zeros(stim_window, n_trials, n_stim);
stim_trial = zeros(1, n_stim);

ntrials = 0;
nskipped = 0;

[psp, time, ws_stimuli] = MeanContinuousByStim(ws_params.filepath, ws_params.duration, ws_params.stim_on);
ws_n_stim = length(ws_stimuli);
ws_stim_on = SAMPLERATE*((ws_params.stim_on)/1000);
ws_stim_off = SAMPLERATE*((ws_params.stim_end)/1000);
for i = 1:ws_n_stim

    temp_psp = psp(:, i);
    ws_psp(:,i) = temp_psp(x>ws_stim_on & x<= ws_stim_off);
    code = ws_stimuli(i);
    ws_angle(i) = StimCodeToDegrees(code); 
end;
figure;
for i = 1:ws_n_stim
    plot(ws_psp(:,i));
    hold on;
end
while (~feof(fvid))
    stimulus_v = StimCodeToDegrees(fread(fvid, 1, 'float32'));
    stimulus_i = StimCodeToDegrees(fread(fiid, 1, 'float32'));
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

    prestim_v = signal_v(x>pre_on  & x<= pre_off ).*100;
    prestim_i = signal_i(x>pre_on  & x<= pre_off );

    stim_v = signal_v(x>stim_on & x<= stim_off).*100;
    %stim_v = stim_v - mean(stim_v);
    stim_i = signal_i(x>stim_on & x<= stim_off);

   
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;

    if PLOT
        h = figure;
        figure(h);
        hold on;
        subplot(2,1,1);
        %plot(prestim_i);
        %ylabel('prestim input');
        %subplot(4,1,2);
        %plot(prestim_v);
        %ylabel('prestim output');
        %subplot(4,1,3);
        plot(stim_i);
        ylabel('stim input');
        subplot(2,1,2);
        plot(stim_v);
        ylabel('stim output');
        set(gcf, 'Name', 'voltage trace');
        plotedit('ON');
    end

    ntrials = ntrials + 1;
    if AP_on_off
        if max(stim_v) > THRESH 
            nskipped = nskipped + 1;
            continue
        end
    end;

    i = find(angle == stimulus);
    stim_trial(i)= stim_trial(i)+1;
    V(:, stim_trial(i), i) = stim_v;
    for j=1:ws_n_stim
        if (stimulus == ws_angle(j))
            stim_v_psp = (stim_v - ws_psp(:,j))-72;
        end
        if (stimulus == angle(1))
           stim_v_psp = stim_v;
        end
        
    end;

    
%     pre_i(:, stim_trial(i), i) = prestim_i*10;
%     pre_v(:, stim_trial(i), i) = prestim_v;
    Stim_i(:, stim_trial(i), i) = stim_i.*10;
    Stim_v(:, stim_trial(i), i) = stim_v_psp;


end
hold off
if nskipped < ntrials
    disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
else
    disp('*********WARNING*********');
    disp(['Skipped' num2str(nskipped) 'of' num2str(ntrials) 'trials!!']);
    disp('Check AP Threshold Setting!!');
end
fclose(fvid);
fclose(fiid);

if chronux_on_off
    for i = 1:n_stim;
        data1 = squeeze(pre_i(:,1:stim_trial(i), i));
        data2 = squeeze(pre_v(:,1:stim_trial(i), i));

        [C_pre, phi, S12_pre,S1_pre,S2_pre,f]= coherencyc(data1,data2,params);
        CSpre(:,  i) = S12_pre;
        Spre_I(:, i) = S1_pre;
        Spre_V(:, i) = S2_pre;
        freq = f;
        Coh_pre(:, i) = C_pre;
        pre_z = abs(S12_pre./S1_pre);
        pre_Z(:,i) = pre_z;

        data3 = squeeze(Stim_i(:,1:stim_trial(i),i));
        data4 = squeeze(Stim_v(:,1:stim_trial(i),i));
        [C_stim,phi_stim,S12_stim,S1_stim,S2_stim,f]= coherencyc(data3,data4,params);
        CSstim(:, i) = S12_stim;
        Sstim_I(:, i) = S1_stim;
        Sstim_V(:, i) = S2_stim;
        freq = f;
        Coh_stim(:,i) = C_stim;
        z = abs(S12_stim./S1_stim);
        Z(:,i) = z;
    end;
else
    figure;
    for i = 1:n_stim
        subplot(n_stim, 1, i);

        stim_i_mean(:,i) = squeeze(mean(Stim_i(:, 1:stim_trial(i), i ), 2));
        stim_v_mean(:,i) = squeeze(mean(Stim_v(:, 1:stim_trial(i), i ), 2));
        V_mean(:, i) = squeeze(mean(V(:, 1:stim_trial(i), i), 2));
        plot(stim_v_mean(:,i));
        hold on;
        plot(V_mean(:, i), 'r');
%         pre_i_mean(:,i) = squeeze(mean(pre_i(:,1:stim_trial(i), i), 2));
%         pre_v_mean(:,i) = squeeze(mean(pre_v(:,1:stim_trial(i), i), 2));

    end


    for i = 1:n_stim
%         [pv, f] = PWELCH(stim_v_mean(:, i), [], [], 3198, SAMPLERATE);
% %         pv = POWERSPEC(stim_v_mean(:, i));
% %         ppv = POWERSPEC(pre_v_mean(:,i));
%         P_v(:, i) = pv;
% %         P_pv(:,i) = ppv;
% 
%         [pi, fi] = PWELCH(stim_i_mean(:, i), [], [], [], SAMPLERATE);
% %         pi = POWERSPEC(stim_i_mean(:, i));
% %         ppi = POWERSPEC(pre_i_mean(:,i));
%         P_i(:,i) = pi;
% %         P_pi(:,i)= ppi;
% 
%         pvi = CROSSSPEC(stim_v_mean(:, i), stim_i_mean(:, i));
% %         ppvi = CROSSSPEC(pre_v_mean(:, i), pre_i_mean(:, i));
%         P_vi(:, i) = pvi;
% %         P_pvi(:, i) = ppvi;
% 
%         z = abs(pvi)./pi;
% %         pz = abs(ppvi)./ppi;
        [Txy, F]= tfestimate(stim_i_mean(:, i), stim_v_mean(:, i), [], [], [], SAMPLERATE);
        Z(:, i) = Txy;
%         pZ(:, i) = pz;
        freq = F;
    end;
end;
[psp, n, stimuli, spon, angle, magnitude, OffOnPSP, OffOnSpikes] = PolarPlots();
good_angle = find(psp == max(psp));
bad_angle = find(psp == min(psp));
max_angle = stimuli(good_angle)
min_angle = stimuli(bad_angle)

figure;
    plot(freq, Z(:, 1), 'g');
    hold on;
    plot(freq, Z(:, good_angle+1), 'r');
    plot(freq, Z(:, bad_angle+1), 'k');
    xlabel('freq (Hz)');
    ylabel('Z');
    legend('no stim', 'best angle', 'worst angle' )
%     legend('0', '45', '90', '135', '180', '225', '270', '315'),
%     legend('no stim','0', '45', '90', '135', '180', '225', '270', '315'),
    xlim([0 wn_params.Fmax]);
    grid on;


