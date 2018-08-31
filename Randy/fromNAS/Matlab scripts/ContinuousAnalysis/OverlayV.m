function h = OverlayVm(filepath, duration, stimOnset, showevery)
% OVERLAYVM(FILEPATH) Average a continuous signal (recorded by
% ntrode.vi) separately for each stimulus condition.
%
% Randy Bruno, June 2003

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
    duration = input('Trial duration in msec: ');
    showevery = 1;
end
if (nargin < 4)
    showevery = str2num(cell2mat(inputdlg('Show every n-th trace? (e.g., 1=all)', 'Parameter for trace overlays', 1, {'1'})));
end

stimuli = ReverseArray(GetStimCodes(filepath, duration));

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

n = zeros(size(stimuli));
minimum = 0;
maximum = 0;
h = figure;
while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid)) break; end;
    signal = fread(fid, nScans, 'float32');
    if (feof(fid)) break; end;
    i = PositionInArray(stimuli, stimulus);
    n(i) = n(i) + 1;
    if (mod(n(i), showevery) == 0)
        subplot(length(n), 1, i);
        line(linspace(0, duration, nScans), signal * SCALINGFACTOR);
        minimum = min([minimum min(signal)]);
        maximum = max([maximum max(signal)]);
    end
end

for i = 1:length(n)
    subplot(length(n), 1, i);
    if (nargin > 2)
        line([stimOnset stimOnset], [minimum, maximum] * SCALINGFACTOR, 'Color', 'green');
    end
    title(['stimulus: ', num2str(stimuli(i))])
    ylim([minimum maximum] * SCALINGFACTOR);
end
xlabel('msec');
set(gcf, 'Name', filepath);

fclose(fid);
