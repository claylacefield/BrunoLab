function [h] = TestResponse(cluster, start1, end1, start2, end2)

% Randy Bruno, January 2013

BINWIDTH = 2; %MSECS

if nargin == 0
    [filename pathname OK] = uigetfile('*.*', 'Select .cluster file to analyze');
    if (~OK) return; end
    filepath = [pathname, filename];
    cluster = ReadCluster(filepath);
end 

if nargin < 5
    start1 = 1;
    end1 = 149;
    start2 = 150;
    end2 = 200;
end

figure;
subplot(2,2,1); PSTH(cluster, start2, end2, [], true, 500, BINWIDTH);
subplot(2,2,2); raster(cluster);

ntrials = length(unique(cluster(:,2))); % must get ntrials before removing null spikes!
clust = RemoveNullSpikes(cluster);
trial = clust(:,2);
timestamp = clust(:,4);

pre = nans(ntrials, 1);
post = nans(ntrials, 1);
for i = 1:ntrials
    pre(i) = length(trial(trial==i & timestamp > start1 & timestamp < end1));
    post(i) = length(trial(trial==i & timestamp > start2 & timestamp < end2));
end
% have to normalize by window lengths in case they're not the same size
pre = pre / (end1-start1);
post = post / (end2-start2);

% nonparametric paired test
% This test tends to miss responses in sparsely active cells.
subplot(2,2,3); hist(post-pre);
[p, h] = signtest(pre, post);
title(['nonparametric paired test (unreliable), p = ' num2str(p) ', h = ' num2str(h)]);

% Poisson test
% This test is much better.
subplot(2,2,4);
[onset, peak] = SpikeLatency2(cluster, start1, end1, 145, start2, end2, [], BINWIDTH, true);
h = ~isnan(onset);
title(['onset latency = ' num2str(onset) ', h = ' num2str(h) ' (reliable)']);
