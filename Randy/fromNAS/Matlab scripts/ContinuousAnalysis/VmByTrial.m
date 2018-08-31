function [Vmean, Vmed, Vmin, Vmax] = VmByTrial(filepath, duration, stimOnset, winstart, winend, trialstart, trialend, plotall)
% VMBYTRIAL(FILEPATH, DURATION, STIMONSET) Average a continuous signal (recorded by
% ntrode.vi) separately for each stimulus condition.
%
% Randy Bruno, June 2003

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
    duration = input('Trial duration in msec: ');
end
if (isempty(winstart) | isempty(winend))
    winstart = 1; % 1 instead of 0 to avoid possible edge effects of median filtering
    winend = 100;
end

if nargin < 8
    plotall = true;
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes
x = linspace(0, duration, SAMPLERATE/1000*duration);

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

Vm = [];
Vmin = [];
Vmax = [];
spon = [];
trial = 0;
while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid)) break; end;
    signal = fread(fid, nScans, 'float32');
    if (feof(fid)) break; end;
    if (trial >= trialstart & trial <= trialend)
        Vm = [Vm, mean(signal)];
        excerpt = signal(x > winstart & x <= winend);
        Vmin = min([Vmin min(excerpt)]);
        %spikes = threshold(excerpt - mean(excerpt), 0.2, 32);
        Vmax = [Vmax max(excerpt)];
%         if isempty(spikes)
%             Vmax = [Vmax max(excerpt)];
%         else
%             disp(['rejected trial #' num2str(trial)])
%         end
        spon = [spon excerpt];
    end
    trial = trial + 1;
end
spon1d = reshape(spon, prod(size(spon)), 1);
Vmed = median(spon1d) * SCALINGFACTOR;
Vmean = mean(spon1d) * SCALINGFACTOR;
Vmin = Vmin * SCALINGFACTOR;
Vmax = Vmax * SCALINGFACTOR;
disp(['spontaneous Vmean =', num2str(Vmean), ', Vmed =', num2str(Vmed), ', Vmin =', num2str(Vmin), ', Vmax =', num2str(max(Vmax)) ' (spike-less)']);

if plotall
    subplot(2,2,1);
end
plot(Vm * SCALINGFACTOR);
xlabel('trial');
ylabel('mean Vm (over both spontaneous & evoked)');
title(filepath);

if plotall
    subplot(2,2,2);
    plot(Vmax);
    ylabel('spontaneous max Vm');
    subplot(2,2,3);
    plot(mean(spon * SCALINGFACTOR));
    ylabel('spontaneous mean Vm');
    subplot(2,2,4);
    plot(min(spon * SCALINGFACTOR));
    ylabel('spontaneous min Vm');
end
set(gcf, 'Name', filepath);

fclose(fid);
