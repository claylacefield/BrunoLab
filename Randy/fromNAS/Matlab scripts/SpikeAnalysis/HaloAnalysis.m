% Long trials when we were switching the laser itself
% WINSTART = 2000;
% WINEND = 2500;
% DURATION = 2500;

% Short trials when we added the shutter
WINSTART = 150;
WINEND = 380;
DURATION = 500;

[clust, filename] = ReadCluster;
%%clust = clust(clust(:,2) > 5, :); %%% REMOVE ME!
laseroff = clust(clust(:,3) > -5000, :);
laseron = clust(clust(:,3) < -5000, :);
laseron(:,3) = laseron(:,3) + 5000;

nstim = length(unique(clust(:,3)))
ntrials = max(clust(:,2)) + 1;

%plot laser ON vs OFF raster
FigH = figure;
subplot(2,1,1);
raster(laseron);
xlabel ('laser on');
subplot(2,1,2);
raster(laseroff);
xlabel ('laser off');


%%% in case of 8 degree master stimulation protocol (45 deg master)
FigI = figure;
if nstim == 16
    PolarSpikes(laseroff, WINSTART, WINEND, ntrials/nstim);
end
subplot(2,2,1);
PSTH(laseroff, WINSTART, WINEND, [], true, DURATION, 1);
subplot(2,2,2);
raster(laseroff);
subplot(2,2,3);
[nspkOff, trialOff] = SpikesPerTrial(laseroff(laseroff(:,4) < WINSTART, :), true);
ylabel('n spontaneous spikes');
[nspkOn, trialOn] = SpikesPerTrial(laseron(laseron(:,4) < WINSTART, :), true);
ylabel('n spontaneous spikes');
subplot(2,2,4);
[nspkOffW, trialOffW] = SpikesPerTrial(laseroff(laseroff(:,4) == 0 | laseroff(:,4) > WINSTART, :), true);
ylabel('n evoked spikes');
set(gcf, 'Name', [filename ' laserOFF']);

figure;
if nstim == 16
    PolarSpikes(laseron, WINSTART, WINEND, ntrials/nstim);
end
subplot(2,2,1);
PSTH(laseron, WINSTART, WINEND, [], true, DURATION, 1);
subplot(2,2,2);
raster(laseron);
subplot(2,2,3);
[nspkOn, trialOn] = SpikesPerTrial(laseron(laseron(:,4) < WINSTART, :), true);
ylabel('n spontaneous spikes');
subplot(2,2,4);
disp('calc laser+whisker')
[nspkOnW, trialOnW] = SpikesPerTrial(laseron(laseron(:,4) == 0 | laseron(:,4) > WINSTART, :), true);
ylabel('n evoked spikes');
set(gcf, 'Name', [filename ' laserON']);

if ~(isempty(nspkOff) && isempty(nspkOn))
    disp('spontaneous:')
    [p,h] = ranksum(nspkOff, nspkOn)
end
if ~(isempty(nspkOff) && isempty(nspkOn))
    disp('evoked:')
    [p,h] = ranksum(nspkOffW, nspkOnW)
end
