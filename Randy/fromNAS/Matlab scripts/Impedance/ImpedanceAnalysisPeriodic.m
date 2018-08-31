function[Imp, delta_z, p_delta_z] = ImpedanceAnalysisPeriodic(wn_params, params, AP_thresh, AP_on_off, chronux_on_off);

THRESH = AP_thresh;
stimuli = ReverseArray(GetStimCodes(wn_params.filepath_v, wn_params.duration))
n_stim = length(stimuli);
nan_window =3;
ws=0;
ww= 0;
for i = 1:n_stim
    if abs(stimuli(i)) <= 360
        ww = ww+1;
        whisker_angles(ww) = stimuli(i);
    elseif abs(stimuli(i)) >= 1000
        ws = ws+1;
        wn_angles(ws) = stimuli(i);
    end
end

n_whisker_stim = length(whisker_angles);
n_wn_stim = length(wn_angles);

if n_whisker_stim ~= n_wn_stim
    error('Different number of whisker and white-noise stim');
else
    n_angles = n_whisker_stim;
end

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

if (nRecs_v~=nRecs_i)
    error('current and voltage recording have different number of trials');return;
end

nRecs = nRecs_v;
n_trials = ceil(nRecs/n_stim);

wn_i = zeros(stim_window, n_trials, n_angles);
wn_v = zeros(stim_window, n_trials, n_angles);
whisker_v = zeros(stim_window, n_trials, n_angles);
null_i = zeros(stim_window, n_trials);
null_v = zeros(stim_window, n_trials);

whisker_trial = zeros(1, n_angles);
wn_trial = zeros(1, n_angles);
null_trial = 0;

ntrials = 0;
nskipped = 0;
trial = 0;



while (~feof(fvid))
    stimulus_v = fread(fvid, 1, 'float32');
    stimulus_i = fread(fiid, 1, 'float32');
    %
    %
    trial = trial +1;
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
        stim_v = signal_v(x>=wn_params.stim_on & x<=wn_params.stim_end).*100;
        %stim_v = stim_v - mean(stim_v);
        stim_i = signal_i(x>=wn_params.stim_on & x<=wn_params.stim_end).*10;


        if (feof(fvid)) break; end;
        if (feof(fiid)) break; end;


        ntrials = ntrials + 1;


        if AP_on_off
            if max(stim_v) > THRESH
                nskipped = nskipped + 1;
                continue
            end
        end;
        if abs(stimulus) >= 1000
            i = find(wn_angles == stimulus);
            wn_trial(i)= wn_trial(i)+1;

            wn_i(:, wn_trial(i), i) = stim_i;
            wn_v(:, wn_trial(i), i) = stim_v;
        elseif stimulus == -999
            null_trial = null_trial +1;
            null_i(:, null_trial) = stim_i;
            null_v(:, null_trial) = stim_v;

        elseif abs(stimulus) <=360
            i = find(whisker_angles == stimulus);
            whisker_trial(i) = whisker_trial(i) +1;
            whisker_v(:, whisker_trial(i), i) = stim_v;
        end
    end




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
null_i_mean = squeeze(mean(null_i(:, 1:null_trial), 2));
null_v_mean = squeeze(mean(null_v(:, 1:null_trial), 2));
i_mean = null_i_mean';
v_mean = null_v_mean';
%save C:/Elaine/080404_model_cell/fentanyl_current.dat i_mean -ASCII
%save C:/Elaine/080404_model_cell/fentanyl_voltage.dat v_mean -ASCII

for i = 1:n_angles
    whisker_v_mean(:, i) = squeeze(mean(whisker_v(:, 1:whisker_trial(i), i), 2));
    wn_i_mean(:, i) = squeeze(mean(wn_i(:, 1:wn_trial(i), i), 2));
    wn_v_mean(:, i) = squeeze(mean(wn_v(:, 1:wn_trial(i), i), 2));
    wn_nopsp_mean(:, i) = wn_v_mean(:, i)-whisker_v_mean(:, i);
end
  
if chronux_on_off

    data1 = null_i_mean;
    data2 = null_v_mean;
    [C_null, phi, S12_null,S1_null,S2_null,f]= coherencyc(data1,data2,params);
    freq = f;
    Coh_null = C_null;
    null_Z = abs(S12_null)./S1_null;
    for l = 1:length(f)
        if Coh_null(l) >=0.95
            good_null_Z(l) = null_Z(l);
        else
            good_null_Z(l)= NaN;
        end
    end
    
    for i = 1:n_angles
        data3 = wn_i_mean(:, i);
        data4 = wn_nopsp_mean(:, i);
        

        [C_wn,phi_wn,S12_wn,S1_wn,S2_wn,f]= coherencyc(data3,data4,params);
        CS_stim(:, i) = S12_wn;
        Sstim_I(:, i) = S1_wn;
        Sstim_V(:, i) = S2_wn;
        freq = f;
        Coh_wn(:,i) = C_wn;
        z = abs(S12_wn)./S1_wn;
        Z(:,i) = z;
        for l = 1:length(f)
            if C_wn(l) >=0.95
                good_Z(l, i) = z(l);
            else
                good_Z(l, i)= NaN;
            end
        end;
    end;
else
    figure;
    for i = 1:n_angles
        subplot(n_angles, 1, i);
        plot(wn_nopsp_mean(:,i));
        hold on;
        plot(wn_v_mean(:, i), 'r');

    end
    [null_Z, F] = tfestimate(null_i_mean, null_v_mean, window, [], [], SAMPLERATE);
 
    for i = 1:n_angles
       
        [Txy, F]= tfestimate(wn_i_mean(:, i), wn_nopsp_mean(:, i), window, [], [], SAMPLERATE);
        Z(:, i) = Txy;
        freq = F;
       
    end;
end;

figure;
plot(freq, null_Z, 'g');
hold on;
plot(freq, Z);


xlabel('freq (Hz)');
ylabel('Z');
legend('no stim', '0', '90', '180' )
    
xlim([0 wn_params.Fmax]);
grid on;

figure;
plot(freq, good_null_Z, 'g');
hold on;
plot(freq, good_Z);


xlabel('freq (Hz)');
ylabel('Z');
legend('no stim', '0', '90', '180' )
xlim([0 wn_params.Fmax]);
grid on;

smooth_null_Z = nanmoving_average(good_null_Z, nan_window);
for i = 1:n_angles
    smooth_Z(:, i) = nanmoving_average(good_Z(:, i), nan_window);
end

freq_null_Z = freq(~isnan(smooth_null_Z));
smooth_null_Z = smooth_null_Z(~isnan(smooth_null_Z));
for i = 1:n_angles
    freq_cell_Z{:, i} = freq(~isnan(smooth_Z(:, i)));
    smooth_cell_Z{:, i} = smooth_Z(~isnan(smooth_Z(:,i)), i);
end

figure;
plot(freq_null_Z, smooth_null_Z, 'g');
hold on;

plot(freq_cell_Z{:, 1}, smooth_cell_Z{:, 1});

plot(freq_cell_Z{:, 2}, smooth_cell_Z{:, 2}, 'k');
plot(freq_cell_Z{:, 3}, smooth_cell_Z{:, 3}, 'r');
xlabel('freq (Hz)');
ylabel('Z');
legend('no stim', '0', '90', '180' )
xlim([0 wn_params.Fmax])
grid on; 