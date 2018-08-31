function [average, x] = MeanContinuous(filepath, duration, stimOnset, PLOT, stimcode, trialstart, trialend)
% MEANCONTINUOUS(FILEPATH) Average a continuous signal (recorded by ntrode.vi).
%
% Randy Bruno, June 2003

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
    duration = input('Trial duration in msec: ');
end

if (nargin < 2)
    duration == 500;
    stimOnset = 145;
end

if (nargin < 4)
    PLOT = true;
end

if nargin < 5
    stimcode = [];
end

if nargin < 7
    trialstart = 0;
    trialend = 1000;
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

n = 0;
average = zeros(nScans, 1);
trial = 0;

while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid)) break; end;
    signal = fread(fid, nScans, 'float32');
    if (feof(fid)) break; end;

    if isempty(stimcode) | (stimulus == stimcode)
        if (trial >= trialstart & trial <= trialend)
            n = n + 1;
            average = MemorylessAverage(average, signal, n);
        end
    end
    trial = trial + 1;
end

average = average * SCALINGFACTOR;

minimum = min(min(average));
maximum = max(max(average));

x = linspace(0, duration, nScans);

if PLOT
    plot(x, average);
    box off;
    if (nargin == 3)
        line([stimOnset stimOnset], [minimum, maximum], 'Color', 'green');
    end

    title(sprintf(strrep(filepath, '\', '\\')));

    ylim([minimum maximum]);

    xlabel('msec');
    set(gcf, 'Name', filepath);
end

fclose(fid);
