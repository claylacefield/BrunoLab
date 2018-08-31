function [p, avg] = BurstAnalysis(clust, winstart, winend, pref)

% BURSTANALYSIS Counts # of trials having 0 spikes, 1 spike, 2 spikes,
% and so on. A limitation of this function is that there is no temporal
% definition here for 'doublet', as an example; two spikes could occur
% quite far apart if the designated analysis window is large enough.
%
% IN
% filepath: full path to a wcp.dat file
%
% OUT
% counts: an 11-element array, where the first element is the # of trials
% in which no spikes occurred, the second element is the # of trials in
% which exactly 1 spike occurred, and so on.
%
% Randy Bruno, December 2003

MAXNSPIKES = 20;

if nargin == 0
    [filename pathname OK] = uigetfile('*.*', 'Select .cluster file to analyze');
    if (~OK) return; end
    filepath = [pathname, filename];
    clust = ReadCluster(filepath);
end 

if nargin < 2
    answers = inputdlg({'Window Start (msec)', 'Window End (msec)'}, 'Parameters for analysis', 1, {'150', '350'});
    winstart = str2num(answers{1});
    winend = str2num(answers{2});
end

% load spike data
ntrials = max(clust(:,2)) + 1;
clust = RemoveNullSpikes(clust);
spiketimes = clust(:, 4);
stimulus = clust(:, 3);
trials = clust(:, 2);

% classify trials into 'burst' types and determine ISIs
count = zeros(MAXNSPIKES+1, 1);
isi = zeros(ntrials, MAXNSPIKES+1);
for i = 1:ntrials
    for j = 1:11
        isi(i, j) = NaN;
    end
end

obs = 0;
for i = 0:(ntrials-1)
    if (nargin < 4) | (stimulus(trials == i) == pref)
        spikes = spiketimes(trials == i & spiketimes >= winstart & spiketimes <= winend);
    
        nspikes = length(spikes);
        if (nspikes > MAXNSPIKES)
            error('trial has more spikes than permitted by MAXNSPIKES; increase # of categories');
        end
        count(nspikes+1) = count(nspikes+1) + 1;
        
        if (nspikes >= 2)
            % determine the ISI of each 'burst' spike and accumulate
            for j = 2:nspikes
                lag = spikes(j) - spikes(j-1);
                %if lag < 100
                    isi(i+1, j+1) = lag;
                    %else
                    %break
                    %end
            end
        end
        obs = obs + 1;
    end
end

p = count/obs;
for i = 1:(MAXNSPIKES+1)
    avg(i) = mean(excise(isi(:, i)));
end
