function FilterSize = FindBestFilters3(filepath, duration)

% FindBestFilters2 allows a user to test different parameters for
% detecting/removing spikes from whole-cell recordings before actually
% removing them. If the user is satisfied at the end, SeparateSpikesAndPSPs
% is called with desired parameters.
%
% In this version, a spike is detected by the derivative crossing a
% threshold. The AHP, which is the most variable part among a burst of
% spikes, is identified from the derivative. Linear interpolation is then
% used to remove the spike (RemoveSpike2.m).

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 2)
    answers = str2num(cell2mat(inputdlg({'duration (msec)'}, 'Parameters', 1, {'1000'})));
    duration = answers(1);
end

thresh = 1;
msPrePeak = 0.5;
msPostPeak = 2.0;
skipFactor = 1;

answers = inputdlg({'derivative threshold (mV)', 'pre-peak time for spike deletion (ms)', 'skip factor'}, ...
    'Parameters for spike filtering', 1, ...
    {num2str(thresh), num2str(msPrePeak), num2str(skipFactor)});
thresh = str2num(answers{1});
msPrePeak = str2num(answers{2});
skipFactor = str2num(answers{3});

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
x = linspace(0, duration, nScans);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

set(gcf, 'Units', 'normalized');
set(gcf, 'Position', [0.1 0.05 0.8 0.85]);

n = 0;
while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid) || isempty(stimulus)) break; end;
    if skipFactor > 1
        fseek(fid, recSize*(skipFactor-1), 'cof');
    end
    signal = fread(fid, nScans, 'float32') * SCALINGFACTOR;
    if (feof(fid) || isempty(signal)) break; end;

    % plot raw signal
    subplot(4,1,1);
    plot(x, signal);
    title([filepath ', record #' num2str(n)]);
        
    % plot derivative
    DECIMATEFACTOR = 1;
    deriv = diff(decimate(signal, DECIMATEFACTOR));
    subplot(4,1,2);
    plot(x(2:end), deriv);
    line([0 duration], [thresh thresh], 'LineStyle', '--');
    drawnow;
    
    % plot signal around first spike, if any, or peak PSP
    time = threshold(deriv, thresh, 64) / (SAMPLERATE / 1000);
    if (isempty(time))
        n = n + 1;
        continue;
    end
    TIMERANGE = 10;
    if (time(1) > TIMERANGE)
        posstart = (time(1) - TIMERANGE) * SAMPLERATE/1000;
    else
        posstart = 2; % scan 2
    end
    if (time(1) < (duration-TIMERANGE))
        posend = (time(1) + TIMERANGE) * SAMPLERATE/1000;
    else
        posend = nScans; % last scan
    end

    subplot(4,1,3);
    plot(x(posstart:posend), signal(posstart:posend), 'LineStyle', ':');
    line(x(posstart:posend), RemoveSpike3(signal(posstart:posend), msPrePeak, thresh));
    xlim([x(posstart) x(posend)]);
    line([0 duration], [thresh thresh], 'LineStyle', '--');
    title('zoom on first spike or max');
    
    subplot(4,1,4);
    plot(x(posstart:posend), signal(posstart:posend), 'LineStyle', ':');
    [y,spikeIndex,PostPeaks] = RemoveSpike3(signal(posstart:posend), msPrePeak, thresh);
    line(x(posstart:posend), y);
    xlim([x(posstart) x(posend)]);
    ylim([-80 thresh]);
    title(['spike deleted, threshold = ' num2str(thresh) ...
        ', pre-peak = ' num2str(msPrePeak) ...
        ', post-peak(s) = ' num2str(PostPeaks')]);
        
    answers = inputdlg({'threshold (mV)', 'pre-peak time for spike deletion (ms)', 'skip factor'}, ...
        'Parameters for spike filtering', 1, ...
        {num2str(thresh), num2str(msPrePeak),num2str(skipFactor)});
    
    if (isempty(answers))
        % cancel was pressed
        break;
    else
        % OK was pressed
        newThresh = str2num(answers{1});
        newPre = str2num(answers{2});
        skipFactor = str2num(answers{3});
      
        if (thresh ~= newThresh || msPrePeak ~= newPre )
            % one of the parameters has changed
            % roll back position so the record gets run again
            % don't incremennt counter
            fseek(fid, -recSize, 'cof');
            thresh = newThresh;
            msPrePeak = newPre;
        else
            % nothing has been changed, so just increment counter
            n = n + skipFactor;
        end
    end
end
fclose(fid);

button = questdlg('Separate spikes and PSPs now using these parameters?', '', 'Yes', 'No', 'No');
if strcmp(button, 'Yes')
    close;
    SeparateSpikesAndPSPs(filepath, duration, thresh, msPrePeak);
end