function AnalyzeCluster(cluster, winstart, winend, name)

% ANALAYZECLUSTER Basic plots for cluster.
%
% Randy Bruno, April 2003

switch nargin
    case 1
        winstart = 150;
        winend = 200;
    case 3
    otherwise
        error('AnalyzeCluster takes 1 or 3 arguments.')
end

figure;
subplot(2, 2, 1); ISIhist(cluster);
subplot(2, 2, 2); acg(cluster);
subplot(2, 2, 3); PSTH(cluster, winstart, winend);
subplot(2, 2, 4); SpikesPerTrial(cluster);
whitebg('white');
drawnow;
