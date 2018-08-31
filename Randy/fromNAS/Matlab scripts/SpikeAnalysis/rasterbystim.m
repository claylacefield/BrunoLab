function rasterbystim(cluster)
% RASTERBYSTIM Raster plot by stim.
% RASTERBYSTIM(CLUSTER) makes a raster plot for each stimulus condition.
% Randy Bruno, May 2004

stimuli = ReverseArray(unique(cluster(:, 3)));
n = length(stimuli);
mx = max(cluster(:, 4));
mx = max(mx, 500);

for i = 1:n
    subplot(n, 1, i);
    clu = cluster(cluster(:, 3) == stimuli(i), :);
    raster(clu, 10);
    xlim([1 mx]);
end
