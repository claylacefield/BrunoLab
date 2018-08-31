function[Imp, delta_z, p_delta_z] = ImpedanceStdErrCoherence(wn_params, params, AP_thresh, AP_on_off, chronux_on_off);
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
recSize = (nScans + 1) * 4; %in bytes

disp(wn_params.filepath_v);
disp(wn_params.filepath_i);

fvid = fopen(wn_params.filepath_v, 'r', 'b');
fiid = fopen(wn_params.filepath_i, 'r', 'b');

headerSize_v = SkipHeader(fvid);
headerSize_i = SkipHeader(fiid);

nRecs_v = floor(GetNumberOfRecords(wn_params.filepath_v, wn_params.duration));
nRecs_i = floor(GetNumberOfRecords(wn_params.filepath_i, wn_params.duration));
params.fpass = [1 10]
params.trialave = 1;
params.err = [2 0.05];
if (nRecs_v~=nRecs_i)
    error('current and voltage recording have different number of trials');return;
end

nRecs = nRecs_v;
n_trials = ceil(nRecs/n_stim);

wn_i = zeros(stim_window, n_trials, n_stim);
wn_v = zeros(stim_window, n_trials, n_stim);

stim_trial = zeros(1, n_stim);

ntrials = 0;
nskipped = 0;
trial = 0;
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
                continue
            end
        end;

        i = find(stimuli == stimulus);
        stim_trial(i)= stim_trial(i)+1;
        wn_i(:, stim_trial(i), i) = stim_i;
        wn_v(:, stim_trial(i), i) = stim_v;
        
        
    end
end

for i = 1:n_stim
    for j = 2:stim_trial(i)    
        j
        data1 = squeeze(mean(wn_i(:, 1:j, i), 2));
        %data1 = wn_i(:, 1:j, i); 
        %data2 = wn_v(:, i:j, i);
        data2 = squeeze(mean(wn_v(:, 1:j, i), 2));
        [C_wn,phi_wn,S12_wn,S1_wn,S2_wn,f, confC, phistd, Cerr]= coherencyc(data1,data2,params);
        Coh_wn(:, j, i) = C_wn;
        Coh_trial_mean(j, i) = mean(C_wn);
        lower_bound_err = Cerr(1, :)';
        Coh_err_wn(:, j, i) = C_wn - lower_bound_err;
        Coh_err_mean(j, i) = mean(C_wn) - mean(lower_bound_err);
    end
end


       
k = [2:1:10];
figure;
[AX,H1,H2]= plotyy(k, Coh_err_mean(2:10, :), k, Coh_trial_mean(2:10, :));
set(H1,'LineStyle','--');
legend(H1, 'stderr1', 'stderr2', 'stderr3', 'stderr4')
legend(H2, 'coh1', 'coh2', 'coh3', 'coh4');
set(get(AX(1),'Ylabel'),'String','StdErr of Coh');
set(get(AX(2),'Ylabel'),'String','Mean Coh 1-10Hz')
xlabel('# of trials');
ylim(AX(2), [0 1])

if nskipped < ntrials
    disp(['Skipped ' num2str(nskipped) ' of ' num2str(ntrials) ' trials.']);
else
    disp('*********WARNING*********');
    disp(['Skipped' num2str(nskipped) 'of' num2str(ntrials) 'trials!!']);
    disp('Check AP Threshold Setting!!');
end
fclose(fvid);
fclose(fiid);
for i = 1:n_stim
    wn_i_mean(:, i) = squeeze(mean(wn_i(:, 1:stim_trial(i), i), 2));
    wn_v_mean(:, i) = squeeze(mean(wn_v(:, 1:stim_trial(i), i), 2));
end

% if chronux_on_off
% 
%     for i = 1:n_stim
%         data3 = squeeze(wn_i(:, 1:stim_trial(i), i));
%         data4 = squeeze(wn_v(:, 1:stim_trial(i), i));
% %         data3 = wn_i_mean(:, i);
% %         data4 = wn_v_mean(:, i);
% 
%         [C_wn,phi_wn,S12_wn,S1_wn,S2_wn,f]= coherencyc(data3,data4,params);
% %         CS_stim(:,:, i) = S12_wn;
% %         Sstim_I(:,:, i) = S1_wn;
% %         Sstim_V(:,:, i) = S2_wn;
%         freq = f;
%         Coh_wn(:,:,i) = C_wn;
% 
%     end;
%     figure;
%     plot(freq, Coh_wn);
%     xlabel('freq (Hz)');
%     ylabel('Coherence');
%     legend('stim1', 'stim2', 'stim3', 'stim4' )
%     xlim([0 wn_params.Fmax]);
%     grid on;
% end