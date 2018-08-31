[filename_v pathname_v OK] = uigetfile('*.dat', 'Select recorded voltage file');
if (~OK) return; end
filepath_v = [pathname_v, filename_v];

[filename_i pathname_i OK] = uigetfile('*.dat', 'Select injected current file');
if (~OK) return; end
filepath_i = [pathname_i, filename_i];

duration = input('Trial duration in msec: ');

stimuli = ReverseArray(GetStimCodes(filepath_v, duration))
%current and voltage files have the same set of stimuli%
%get unique set of stimuli%
n_stim = length(stimuli);
SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
N_fft = 2^nextpow2(nScans);
recSize = (nScans + 1) * 4; %in bytes

fvid = fopen(filepath_v, 'r', 'b');
fiid = fopen(filepath_i, 'r', 'b');

headerSize_v = SkipHeader(fvid);
headerSize_i = SkipHeader(fiid);

nRecs_v = floor(GetNumberOfRecords(filepath_v, duration));
nRecs_i = floor(GetNumberOfRecords(filepath_i, duration));

if (nRecs_v~=nRecs_i)
    error('current and voltage recording have different number of trials'); end

nRecs = nRecs_v;
n_trials = ceil(nRecs/n_stim);
figure;
hold on;
%skip = 0;%SAMPLERATE*0.148;
I = zeros(n_stim, n_trials, nScans);
V = zeros(n_stim, n_trials, nScans);
Z = zeros(n_stim, n_trials, N_fft);
stim_trial = zeros(1, n_stim);
%%%
%data = cell(n_stim, n_trials);
%d = cell(n_stim, 1);
%Z = cell(n_stim, 1);
%%%
mean_If=zeros(N_fft,1);
mean_Vf=zeros(N_fft,1);
while (~feof(fvid))
    stimulus_v = fread(fvid, 1, 'float32');
    stimulus_i = fread(fiid, 1, 'float32');
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;
    if (stimulus_v ~= stimulus_i) break; end;

    stimulus = stimulus_v;

    %skipped_v = fread(fvid, skip, 'float32');
    %skipped_i = fread(fiid, skip, 'float32');

    signal_v = fread(fvid, nScans, 'float32');
    signal_i = fread(fiid, nScans, 'float32');
    if (feof(fvid)) break; end;
    if (feof(fiid)) break; end;


    for i= 1:n_stim

        if stimuli(i) == stimulus
            %stimulus
            i
            stim_trial(i)= stim_trial(i)+1;
            I(i, stim_trial(i), :)= signal_i;
            V(i, stim_trial(i), :)= signal_v;
            %data = iddata(V, I, 1/SAMPLERATE);
            I_f=abs(fft(signal_i, N_fft)/(N_fft/2));
            
            %mean_If=(mean_If+I_f)/stim_trial(i);
            V_f=abs(fft(signal_v, N_fft)/(N_fft/2));
            
            %mean_Vf=(mean_Vf+V_f)/stim_trial(i);
            Z(i, stim_trial(i),:)= (I_f.*V_f)./(V_f.*V_f);
            %data(i, stim_trial(i))= {iddata(signal_v, signal_i, 1/SAMPLERATE)};
            %Z(i, stim_trial(i))={etfe(data{i, stim_trial(i)},[],1000)};

        end;
    end;


end
freq = SAMPLERATE/2*linspace(0,1,N_fft/2);
%for i=1:n_stim
%d= merge(data{i,1:stim_trial(i)});
%Z(i)=etfe(d{i},[],1000);
%end
%plot(signal_v);
%%%%%the above scripts only saves data for one certain stimuli, and do not
%%%%%save them in a matrix, which is what i need to do for both the signal
%%%%%type as well as the actual voltage data.




%fclose(fid);