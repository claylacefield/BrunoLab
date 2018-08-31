function [average, x, stimuli] = MeanContinuousByStim(filepath, duration, stimOnset, checkCodes, trialstart, trialend, PLOT)
% MEANCONTINUOUSBYSTIM(FILEPATH) Average a continuous signal (recorded by
% ntrode.vi) separately for each stimulus condition.
%
% INPUT
% filepath: path to file to process
% duration: length of each trial in msecs
% stimOnset: onset time of stimulus within trial (in msecs) - e.g., 145
% checkCodes: true if you want to check that all stimulus codes are
% negative integers; false if you want to ignore stimulus code values
% trialstart: first trial to analyze (usually 0)
% trialend: last trial to analyze (set to a large # if you want to analyze
% all)
%
% OUTPUT
% average: time x stimcondition matrix of average membrane potential
% x: time base in msecs
% stimuli: array of stimulus codes
%
% Randy Bruno, June 2003
% added PLOT May 2013

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
    duration = input('Trial duration in msec: ');
end

if (nargin < 2)
    duration = 500;
    stimOnset = 145;
end

if nargin < 4
    checkCodes = true;
end

if nargin < 6
    trialstart = 0;
    trialend = 1000;
end

if nargin < 7
    PLOT = true;
end

stimuli = ReverseArray(GetStimCodes(filepath, duration, checkCodes));

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

n = zeros(size(stimuli));
average = zeros(nScans, length(stimuli));
trial = 0;

while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid)) break; end;
    signal = fread(fid, nScans, 'float32');
    if (feof(fid)) break; end;

    if trial >= trialstart & trial <= trialend
        i = PositionInArray(stimuli, stimulus);
        n(i) = n(i) + 1;
        average(:, i) = MemorylessAverage(average(:, i), signal, n(i));
    end
    trial = trial + 1;
end

average = average * SCALINGFACTOR;
x = linspace(0, duration, nScans);

if PLOT
    minimum = min(min(average));
    maximum = max(max(average));
    for i = 1:length(n)
        subplot(length(n), 1, i);
        plot(x, average(:, i));
        box off;
        if (nargin == 3)
            line([stimOnset stimOnset], [minimum, maximum], 'Color', 'green');
        end
        if (i==1)
            title(sprintf([strrep(filepath, '\', '\\') '\nstimulus: ', num2str(stimuli(i))]));
        else
            title(['stimulus: ', num2str(stimuli(i))])
        end
        ylim([minimum maximum]);
    end
    xlabel('msec');
    set(gcf, 'Name', filepath);
end

fclose(fid);
