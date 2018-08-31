function [CV, ss, ms] = CVSpikeCounts(cluster, winstart, winend)

% CVSPIKECOUNTS. Calculates the coefficient of variation of trial-to-trial
% spiking for a single cell.
% Randy Bruno, October 2005

if nargin == 0
    cluster = ReadCluster;
end

if nargin < 3
    winstart = 145;
    winend = 295;
end

ntrial = max(cluster(:,2)) + 1;
stimulus = StimCodeToDegrees(cluster(:,3));
stimuli = unique(stimulus);
nStim = length(stimuli);

nreps = ntrial;
trial = cluster(:, 2);
%tr = unique(trial);
%for i = 1:length(tr)
%    trial(trial==tr(i)) = i-1; %renumbers trials to be consecutive integers
%end
timestamp = cluster(:,4);

nspikes = nans(nreps, 1);
for i = 0:(nreps-1)
    nspikes(i+1) = length(timestamp(timestamp >= winstart & timestamp < winend & trial==i));
end
raster(cluster);
disp(nspikes);
ss = std(nspikes);
ms = mean(nspikes);
CV = ss / ms
