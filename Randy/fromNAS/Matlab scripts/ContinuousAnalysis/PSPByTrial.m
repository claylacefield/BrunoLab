function [binstart, binend, psps] = PSPByTrial(filepath, duration, winstart, winend, trialstart, trialend, bin, posgoing)
% PSPBYTRIAL(FILEPATH, DURATION, STIMONSET) 
%
% Outputs:
% Vm: the mean Vm over all trials (whole trial)
% Vmed: the median Vm over all trials
% Vmin: an array containing the min Vm for each trial (window only)
% Vmax: an array containing the max Vm for each trial (window only)
% Vmean: an array containing the mean Vm of each trial (window only)
%
% Randy Bruno, June 2003

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 9)
    answers = inputdlg({'duration (ms)', 'winstart (ms)', 'winend (ms)', 'trialstart', 'trialend', 'trial bin', 'positive going?'}, ...
        'Parameters for PSPByTrial analysis', 1, ...
        {'500', '150', '200', '0', '1000', '1', '0'});
    duration = str2num(answers{1});
    winstart = str2num(answers{2});
    winend = str2num(answers{3});
    trialstart = str2num(answers{4});
    trialend = str2num(answers{5});
    bin = str2num(answers{6});
    posgoing = str2num(answers{7});
end

if (isempty(winstart) | isempty(winend))
    winstart = 1; % 1 instead of 0 to avoid possible edge effects of median filtering
    winend = 100;
end

nrecs = floor(GetNumberOfRecords(filepath, duration));

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes
x = linspace(0, duration, SAMPLERATE/1000*duration);

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

psps = zeros(ceil(nrecs / bin), 1);
trial = 0;
while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid)) break; end;
    signal = fread(fid, nScans, 'float32');
    if (feof(fid)) break; end;
    if (trial >= trialstart & trial <= trialend)
        baseline = median(signal(x > (winstart - 10) & x < winstart));
        if posgoing==1
            peak = max(signal(x >= winstart & x <= winstart + 50));
        else
            peak = min(signal(x >= winstart & x <= winstart + 50));
        end
        psp = peak-baseline;
        i = floor(trial / bin) + 1;
        n = mod(trial, bin) + 1;
        psps(i) = MemorylessAverage(psps(i), psp, n);
    end
    trial = trial + 1;
end
fclose(fid);

psps = psps * SCALINGFACTOR;
binstart = 0:bin:nrecs;
binstart = binstart';
binend = (bin-1):bin:nrecs;
binend = binend';
if length(binend) > length(psps)
    binend = binend(1:(end-1));
end
figure;
plot(binend, psps, 'Color', 'k');
axis tight;
box off;
xlabel('trial');
ylabel('psp (mV)');
title(filepath);
set(gcf, 'Name', filepath);


