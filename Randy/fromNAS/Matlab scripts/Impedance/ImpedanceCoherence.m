function[Imp, delta_z, p_delta_z] = ImpedanceCoherence(wn_params, params, AP_thresh, AP_on_off, chronux_on_off);
PLOT = false;
THRESH = AP_thresh;
stimuli = ReverseArray(GetStimCodes(wn_params.filepath_v, wn_params.duration))
n_stim = length(stimuli);
window = 5000;
ws=0;
ww= 0;

SCALINGFACTOR = 100;
SAMPLERATE = params.Fs; % in Hz

nScans = SAMPLERATE * (wn_params.duration / 1000);
stim_on = SAMPLERATE*((wn_params.stim_on)/1000);
stim_off = SAMPLERATE*((wn_params.stim_end)/1000);
x = linspace(0, wn_params.duration, nScans);

stim_window = stim_off - stim_on;
trial_start = wn_params.trial_start;
trial_end = wn_params.trial_end;

%x = 0:(nScans-1);
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
    error('current and voltage recording have different number of trials');return;
end

nRecs = nRecs_v;
n_trials = ceil(nRecs/n_stim);

wn_i = zeros(stim_window, n_trials, n_stim);
wn_v = zeros(stim_window, n_trials, n_stim);
AP_i = zeros(stim_window, n_trials, n_stim);
AP_v = zeros(stim_window, n_trials, n_stim);

stim_trial = zeros(1, n_stim);
AP_stim_trial = zeros(1, n_stim);

ntrials = 0;
nskipped = 0;
trial = 0;
params.fpass = [1 100]
while (~feof(fvid))
    stimulus_v = fread(fvid, 1, 'float32');
    stimulus_i = fread(fiid, 1, 'float32');
    %
    %
    trial = trial + 1;
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
    if (trial >= trial_start) & (trial <= trial_end)

        stim_v = signal_v(x>=wn_params.stim_on & x<= wn_params.stim_end).*100;
        %stim_v = stim_v - mean(stim_v);
        stim_i = signal_i(x>=wn_params.stim_on & x<= wn_params.stim_end).*10;


        if (feof(fvid)) break; end;
        if (feof(fiid)) break; end;
        ntrials = ntrials + 1;


        if AP_on_off
            if max(stim_v) > THRESH
                nskipped = nskipped + 1;
                k = find(stimuli == stimulus);
                AP_stim_trial(k) = AP_stim_trial(k)+1;
                AP_i(:, AP_stim_trial(k), k) = stim_i;
                AP_v(:, AP_stim_trial(k), k) = stim_v;
                continue
            end
        end;

        i = find(stimuli == stimulus);
        stim_trial(i)= stim_trial(i)+1;
        wn_i(:, stim_trial(i), i) = stim_i;
        wn_v(:, stim_trial(i), i) = stim_v;

        hold off



    end
end
if nskipped < ntrials
    disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
else
    disp('*********WARNING*********');
    disp(['Skipped' num2str(nskipped) 'of' num2str(ntrials) 'trials!!']);
    disp('Check AP Threshold Setting!!');
end
% save C:\Elaine\ntrode_data\080718\file12_AP_v.dat AP_v
% save C:\Elaine\ntrode_data\080718\file12_AP_i.dat AP_i
% save C:\Elaine\ntrode_data\080718\file12_wn_v.dat wn_v
% save C:\Elaine\ntrode_data\080718\file12_wn_i.dat wn_i
fclose(fvid);
fclose(fiid);

if AP_on_off

    for i = 1:n_stim
        n_stim_trial(i) = min(AP_stim_trial(i), stim_trial(i))
        AP_i_mean(:, i) = squeeze(mean(AP_i(:, 1:n_stim_trial(i), i), 2));
        AP_v_mean(:, i) = squeeze(mean(AP_v(:, 1:n_stim_trial(i), i), 2));
        wn_i_mean(:, i) = squeeze(mean(wn_i(:, 1:n_stim_trial(i), i), 2));
        wn_v_mean(:, i) = squeeze(mean(wn_v(:, 1:n_stim_trial(i), i), 2));
    end

    

        for i = 1:n_stim
            %         data3 = squeeze(wn_i(:, 1:stim_trial(i), i));
            %         data4 = squeeze(wn_v(:, 1:stim_trial(i), i));
            data1 = AP_i_mean(:, i);
            data2 = AP_v_mean(:, i);

            [C_wn,phi_wn,S12_wn,S1_wn,S2_wn,f]= coherencyc(data1,data2,params);
            %         CS_stim(:,:, i) = S12_wn;
            %         Sstim_I(:,:, i) = S1_wn;
            %         Sstim_V(:,:, i) = S2_wn;
            freq = f;
            Coh_AP(:,i) = C_wn;

        end;
        figure;
        plot(freq, Coh_AP);
        xlabel('freq (Hz)');
        ylabel('Coherence');
        legend('stim1', 'stim2', 'stim3', 'stim4' )
        xlim([0 wn_params.Fmax]);
        grid on;
        for i = 1:n_stim
            data3 = wn_i_mean(:, i);
            data4 = wn_v_mean(:, i);

            [C_wn,phi_wn,S12_wn,S1_wn,S2_wn,f]= coherencyc(data3,data4,params);
            %         CS_stim(:,:, i) = S12_wn;
            %         Sstim_I(:,:, i) = S1_wn;
            %         Sstim_V(:,:, i) = S2_wn;
            freq = f;
            Coh_wn(:,i) = C_wn;
        end;
    
    figure;
    plot(freq, Coh_wn);
    xlabel('freq (Hz)');
    ylabel('Coherence');
    legend('stim1', 'stim2', 'stim3', 'stim4' )
    xlim([0 wn_params.Fmax]);
    grid on;


save C:\Elaine\ntrode_data\AP_Coh.dat Coh_AP -APPEND
save C:\Elaine\ntrode_data\wn_Coh.dat Coh_wn -APPEND


else
    for i = 1:n_stim
        wn_i_mean(:, i) = squeeze(mean(wn_i(:, 1:stim_trial(i), i), 2));
        wn_v_mean(:, i) = squeeze(mean(wn_v(:, 1:stim_trial(i), i), 2));
    end
    if chronux_on_off

        for i = 1:n_stim
            %         data3 = squeeze(wn_i(:, 1:stim_trial(i), i));
            %         data4 = squeeze(wn_v(:, 1:stim_trial(i), i));
            data3 = wn_i_mean(:, i);
            data4 = wn_v_mean(:, i);

            [C_wn,phi_wn,S12_wn,S1_wn,S2_wn,f]= coherencyc(data3,data4,params);
            %         CS_stim(:,:, i) = S12_wn;
            %         Sstim_I(:,:, i) = S1_wn;
            %         Sstim_V(:,:, i) = S2_wn;
            freq = f;
            Coh_wn(:,i) = C_wn;

        end;
        figure;
        plot(freq, Coh_wn);
        xlabel('freq (Hz)');
        ylabel('Coherence');
        legend('stim1', 'stim2', 'stim3', 'stim4' )
        xlim([0 wn_params.Fmax]);
        grid on;


    end
end