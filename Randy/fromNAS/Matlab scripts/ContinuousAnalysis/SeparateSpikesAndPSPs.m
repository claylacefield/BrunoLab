function SeparateSpikesAndPSPs(filepath, duration, thresh, msPrePeak, tailScaler)

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 2)
    answers = str2num(cell2mat(inputdlg({'duration (msec)'}, 'Parameters', 1, {'500'})));
    duration = answers(1);
end

if (nargin < 3)
    answers = inputdlg({'derivative threshold (mV)', 'pre-peak time for spike deletion (ms)', 'multiple of derivative-based time to delete'}, ...
        'Parameters for spike filtering', 1, ...
        {'1', '0.5', '1.0'});
    thresh = str2num(answers{1});
    msPrePeak = str2num(answers{2});
    tailScaler = str2num(answers{3});
 end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
SAMPLESPERMS = SAMPLERATE / 1000;
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

SpikesPath = [filepath(1:(length(filepath)-4)) '-spikes.cluster1']
PspPath = [filepath(1:(length(filepath)-4)) '-psp.dat']

sid = fopen(SpikesPath, 'w');
pid = fopen(PspPath, 'w', 'b');
fprintf(pid, '%%%%ENDHEADER\n'); %writes %%ENDHEADER

figure;

nspikes = 0;
ntrials = 0;
while (~feof(fid))
    % read stimulus code and whole-cell trace
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid) || isempty(stimulus)) break; end;
    if (stimulus > 0)
        errordlg('SeparateSpikesAndPSPs.m encountered an invalid stimulus code. Check that correct datafile and trial duration have been selected.');
        return
    end   
    signal = SCALINGFACTOR * fread(fid, nScans, 'float32');
    if (feof(fid) || isempty(signal)) break; end;

    %fsignal = medfilt1(signal, SAMPLERATE/1000 * FilterSize); % median-filter whole-cell data
    fsignal = RemoveSpike4(signal, msPrePeak, tailScaler, thresh);
    
    fwrite(pid, stimulus, 'float32'); % write stimulus code
    fwrite(pid, fsignal / SCALINGFACTOR, 'float32'); % and filtered data to psp file

    % write a null spike to indicate trial start (just like during extracellular
    % data acquisition)
    record = [nspikes ntrials stimulus 0];
    fprintf(sid, '%d\t%d\t%d\t%d\r\n', record);
    nspikes = nspikes + 1;

    %spiketimes = threshold((signal - fsignal), 10, 64) / (SAMPLESPERMS);
    %spiketimes = threshold(signal, thresh, SAMPLESPERMS * 2) / SAMPLESPERMS;
    deriv = diff(signal);
    spiketimes = threshold(deriv, thresh, SAMPLESPERMS * 2); % threshold the spikes to find indexes
    spiketimes = spiketimes' + 1; % correct for offset caused by diff function
    spiketimes = spiketimes / SAMPLESPERMS;
    % if the cell spiked, write all the spikes...
    if (~isempty(spiketimes))
        for time = spiketimes
            record = [nspikes ntrials stimulus round(time*10)];
            fprintf(sid, '%d\t%d\t%d\t%d\r\n', record);
            nspikes = nspikes + 1;
        end
    end
    
    mi = min([signal; fsignal]);
    ma = max([signal; fsignal]);
    subplot(5,1,1);
    plot(signal);
    ylim([mi ma]);
    title(['record ' num2str(ntrials)]);
    subplot(5,1,2);
    plot(fsignal);
    ylim([mi ma]);
    subplot(5,1,3);
    plot(signal - fsignal);
    if (~isempty(spiketimes))
        excerptstart = SAMPLESPERMS*(spiketimes(1)-2);
        excerptend = SAMPLESPERMS*(spiketimes(1)+4);
        if excerptend > length(signal)
            excerptend = length(signal);
        elseif excerptstart < 1
            excerptstart = 1;
        end
        mi = min([signal(excerptstart:excerptend); fsignal(excerptstart:excerptend)]);
        ma = max([signal(excerptstart:excerptend); fsignal(excerptstart:excerptend)]);
        subplot(5,1,4);
        plot(signal(excerptstart:excerptend));
        subplot(5,1,5);
        plot(fsignal(excerptstart:excerptend));
    end

    drawnow;
    %button = questdlg('Do you want to continue?', 'Continue Operation','Yes','No', 'No');
    %if strcmp(button,'No')
    %    break;
    %end
   
    ntrials = ntrials + 1;
end
fclose(fid);
fclose(pid);
fclose(sid);
