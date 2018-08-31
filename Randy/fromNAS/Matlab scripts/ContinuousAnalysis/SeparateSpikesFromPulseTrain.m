function SeparateSpikesFromPulseTrain(filepath, FilterSize, duration, trainStart, npulses, pulsedur, ipi, CTwindow)

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 9)
    answers = inputdlg({'median filter size(ms)', 'duration (ms)', 'train start time (ms)', '# of pulses', 'pulse duration (ms)', 'inter-pulse interval (ms)', 'capacitative transient window (ms)', 'spike threshold level (mV)'}, ...
        'Parameters for spike identification', 1, ...
        {'4.0', '2000', '100', '5', '200', '200', '1', '1.5'});
    FilterSize = str2num(answers{1});
    duration = str2num(answers{2});
    trainStart = str2num(answers{3});
    npulses = str2num(answers{4});
    pulsedur = str2num(answers{5});
    ipi = str2num(answers{6});
    CTwindow = str2num(answers{7});
    level = str2num(answers{8});
end

% determine times of capacitative transients
transients = zeros(1,0);
for i = 1:npulses
    transients = [transients, trainStart + (i-1)*(pulsedur + ipi), trainStart + i*pulsedur + (i-1)*ipi];
end
transients

Plots = true;
SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
SAMPLESPERMS = SAMPLERATE / 1000;
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

SpikesPath = [filepath(1:(length(filepath)-4)) '-spikes.cluster1']
PspPath = [filepath(1:(length(filepath)-4)) '-psp.dat'];

sid = fopen(SpikesPath, 'w');
%pid = fopen(PspPath, 'w', 'b');
%fprintf(pid, '%%%%ENDHEADER\n'); %writes %%ENDHEADER

if Plots
    figure;
end

nspikes = 0;
ntrials = 0;
while (~feof(fid))
    % read stimulus code and whole-cell trace
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid) | isempty(stimulus)) break; end;
    if (stimulus > -1)
        errordlg('SeparateSpikesFromPulseTrain.m encountered an invalid stimulus code. Check that correct datafile and trial duration have been selected.');
        return
    end   
    signal = SCALINGFACTOR * fread(fid, nScans, 'float32');
    if (feof(fid) | isempty(signal)) break; end;

    fsignal = medfilt1(signal, SAMPLERATE/1000 * FilterSize); % median-filter whole-cell data
    %fsignal = RemoveSpike(signal);
    
    %fwrite(pid, stimulus, 'float32'); % write stimulus code
    %fwrite(pid, fsignal / SCALINGFACTOR, 'float32'); % and filtered data to psp file

    % write a null spike to indicate trial start (just like during extracellular
    % data acquisition)
    record = [nspikes ntrials stimulus 0];
    fprintf(sid, '%d\t%d\t%d\t%d\r\n', record);
    nspikes = nspikes + 1;

    spiketimes = threshold((signal - fsignal), level, 64) / (SAMPLESPERMS);
    spiketimes = spiketimes';
    original = spiketimes;
    
    % if the cell spiked...
    if (length(spiketimes) > 0)
        % remove anything occuring around times of capacitative transients
        for i = transients
            spiketimes = spiketimes(spiketimes < i | spiketimes > i+CTwindow);
        end
        
        % write spikes
        for time = spiketimes
            record = [nspikes ntrials stimulus round(time*10)];
            fprintf(sid, '%d\t%d\t%d\t%d\r\n', record);
            nspikes = nspikes + 1;
        end
    end
    
    if (Plots)
        mi = -10;
        ma = 10;
        subplot(5,1,1);
        plot(signal);
        xlim([1 nScans]);
        ylim([mi ma]);
        subplot(5,1,2);
        plot(fsignal);
        xlim([1 nScans]);
        ylim([mi ma]);
        subplot(5,1,3);
        plot(signal - fsignal);
        xlim([1 nScans]);
        if (length(spiketimes) > 0)
            subplot(5,1,4);
            scatter(original * SAMPLESPERMS, repmat(1, size(original)));
            xlim([1 nScans]);
            subplot(5,1,5);
            scatter(spiketimes * SAMPLESPERMS, repmat(1, size(spiketimes)));
            xlim([1 nScans]);
        else
            subplot(5,1,4);
            scatter(0, 0);
            xlim([1 nScans]);
            subplot(5,1,5);
            scatter(0, 0);
            xlim([1 nScans]);
        end
   
        drawnow;
        %button = questdlg('Do you want to continue?', 'Continue Operation','Yes','No', 'No');
        %if strcmp(button,'No')
        %    break;
        %end
    end
    
    ntrials = ntrials + 1;
end
fclose(fid);
fclose(sid);
