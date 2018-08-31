function [nspikes, x, nstim] = PSTHbyStim(cluster, winstart, winend, Plots, binmax, binwidth)
% PSTH Peri-stimulus time histograms for each stimulus applied.
% PSTH(CLUSTER) plots PSTHs by stimulus for the spike data contained in cluster.
% Randy Bruno, May 2003

if nargin == 1
    winstart = 150;
    winend = 170;
end

if nargin < 6
    binwidth = 1;
end

if nargin < 5 || isempty(binmax)
    binmax = ceil(max(cluster(:,4)));
end

if nargin < 4
    Plots = true;
end

ntrials = max(cluster(:,2)) + 1;

stimulus = cluster(:,3)';
stimtypes = ReverseArray(sort(unique(stimulus)));
nstim = length(stimtypes);

i = 0;
nspikes = [];
nspk = []; % wasn't sure what nspikes was used for, leave alone
disp(stimtypes)
for stim = stimtypes
    i = i + 1;
    if (Plots) subplot(nstim+1, 1, i); end
    clust = cluster(stimulus==stim, :);
    if nrows(clust)
        [n, x] = PSTH(clust, winstart, winend, stim, Plots, binmax, binwidth);
    end
    if (Plots)
        title(stim);
        box off;
    end
    nspikes = [nspikes n];
    nspk = [nspk sum(n(x>=winstart & x<winend))];
end

if (Plots)
    % plot tuning curve
    subplot(nstim+1, 1, nstim+1);
    plot(stimtypes, nspk);
end