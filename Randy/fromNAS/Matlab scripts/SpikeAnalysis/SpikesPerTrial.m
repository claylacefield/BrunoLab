function [nSpikes, trial] = SpikesPerTrial(cluster, PLOT)

% SPIKESPERTRIAL(CLUSTER) plots the number of spikes per trial for spike
% data in cluster. Good for checking for electrode drift.
% Randy Bruno, April 2003

trial = cluster(:,2);
ntrials = length(unique(trial+1)); % number of trials with or without spikes
bins = min(trial):max(trial); % get ALL trial #'s before deleting null spikes

cluster = RemoveNullSpikes(cluster);
trial = cluster(:,2); % get real spikes
[n, x] = hist(trial, bins);
if isempty(n)
    disp('no spikes')
    disp(ntrials)
    n = zeros(1, ntrials);
end

if nargin == 1 | PLOT
    plot(x, n);
    axis([-Inf Inf -Inf Inf])
    xlabel('trial');
    ylabel('number of spikes');
    title(['total number of spikes = ', num2str(sum(n))]);
    if sum(n)
        model = polyfit(x, n, 1);
        hold on;
        plot(x, polyval(model, x))
        hold off;
    end
end

nSpikes = n;
trial = x;
