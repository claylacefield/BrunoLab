function [prefpsp, meanpsp, xp, prefspk, meanspk, xs] = TuningTimeCourse(filepath, duration, stimOnset, winstart, winend)
%
% TUNINGTIMECOURSE(FILEPATH, DURATION, STIMONSET, WINSTART, WINEND)
% Examine time course of angular tuning for whole-cell data.
%
% Randy Bruno, March 2004

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 5)
    answers = inputdlg({'Duration (msec)', 'Stimulus Onset (msec)', 'Window Start (msec)', 'Window End (msec)'}, 'Parameters for analysis', 1, {'500', '145', '150', '350'});
    duration = str2num(answers{1});
    stimOnset = str2num(answers{2});
    winstart = str2num(answers{3});
    winend = str2num(answers{4});
end

stimuli = ReverseArray(GetStimCodes(filepath, duration));

% find best direction(s)
[psp, n, x, spon] = PolarPlots(filepath, duration, stimOnset, winstart, winend, false, 0, Inf);
PrefDirPSP = find(psp == max(psp));
PrefDirPSP = PrefDirPSP(1);
PrefDirPSP = stimuli(PrefDirPSP);
PrefDirSpk = find(n == max(n));
PrefDirSpk = PrefDirSpk(1);
PrefDirSpk = stimuli(PrefDirSpk);

% average PSP for best direction
figure;
subplot(3, 2, 1);
pspfile = [filepath(1:(length(filepath)-4)) '-psp.dat'];
[prefpsp, xp] = MeanContinuous(pspfile, duration, stimOnset, true, PrefDirPSP);
title([pspfile ', preferred direction']);

% mean PSP
subplot(3, 2, 3);
[meanpsp, xp] = MeanContinuous(pspfile, duration, stimOnset, true);
title('averaged over all directions');

% subtraction
subplot(3, 2, 5);
prefpsp = prefpsp - median(prefpsp(xp > (winstart - 10) & xp < winstart));
meanpsp = meanpsp - median(meanpsp(xp > (winstart - 10) & xp < winstart));
plot(xp, prefpsp - meanpsp);
box off;
title('preferred - averaged');

% PSTH over all directions
clusterfile = [filepath(1:(length(filepath)-4)) '-spikes.cluster1']
cluster = ReadCluster(clusterfile);
subplot(3, 2, 4);
[meanspk, xs] = PSTH(cluster, winstart, winend, [], true, 500, 1);
xlim([0 500]);

% PSTH for best direction
cluster = cluster(cluster(:, 3) == PrefDirSpk, :);
subplot(3, 2, 2);
[prefspk, xs] = PSTH(cluster, winstart, winend, [], true, 500, 1);
xlim([0 500]);
plotedit on;

% subtraction
subplot(3, 2, 6);
plot(xs, prefspk - meanspk);

orient landscape;
