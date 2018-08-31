function [onset, peak] = SpikeLatency(cluster, stimOnset, winstart, winend, alpha, binwidth, PLOT)

% LATENCY = SPIKELATENCY(CLUSTER, WINSTART, WINEND, ALPHA, BINWIDTH)
%
% Returns earliest onset latency of cluster computed from PSTH.
% Does not take into account angular preferences.
%
% CLUSTER: standard cluster file
% WINSTART: start of window to begin looking for significant responses (ms)
% WINEND: end of window (ms)
% ALPHA: alpha value for determining what is a 'significant' response
% BINWIDTH: size of bins used in constructing PSTH (ms)
%
% Randy Bruno, February 2004

if nargin < 7
    PLOT = true;
end

if nargin < 6
    alpha = 0.01;
    binwidth = 1;
end

if nargin < 4
    stimOnset = 145;
    winstart = 149;
    winend = 245;
end

if nargin < 1
    cluster = ReadCluster;
end

%EXTRACT BACKWARDS DIRECTION
cluster = ExtractCondition(cluster, -25)

% because spike rates for cortical cells can be low, analysis is performed on PSTH
[n, x] = PSTH(cluster, winstart, winend, [], PLOT, winend, binwidth);

% remove normalization by ntrials (so we are dealing with absolute spike
% counts per bin)
ntrials = length(unique(cluster(:,2)));
n = n * ntrials;

% compute average spontaneous spikes per bin
spon = mean(n(x >= 1 & x <= 101));

% given this number of spontaneous spikes, what number exceeds
% the alpha (is substantially different from spontaneous)?
crit = poissinv(1 - alpha, spon);

% return onset latency, first bin exceeding the critical value (NA if none)
sigbins = find(n > crit)
sigbins = x(sigbins);
sigbins = sigbins(sigbins > winstart);
if isempty(sigbins)
    onset = NaN;
else
    onset = sigbins(1) - stimOnset;
end

% return peak latency, max bin
peak = find(n == max(n));
peak = x(peak);
peak = peak(peak > winstart);
if isempty(peak)
    peak = NaN;
else
    peak = peak(1) - stimOnset;
end

if PLOT
    title(['mean spontaneous spikes / stim / bin = ' num2str(spon / ntrials), ...
           ', mean spontaneous spikes / bin = ' num2str(spon), ...
           ', onset latency = ' num2str(signif(onset, 1))]);
end
