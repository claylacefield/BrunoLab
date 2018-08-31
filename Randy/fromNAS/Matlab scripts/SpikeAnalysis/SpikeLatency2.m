function [onset, peak] = SpikeLatency2(cluster, basestart, baseend, stimOnset, winstart, winend, alpha, binwidth, PLOT)

% [ONSET, PEAK] = SPIKELATENCY2(CLUSTER, WINSTART, WINEND, ALPHA, BINWIDTH)
%
% Returns onset and modal latencies of cluster computed from PSTH.
% Does not take into account angular preferences.
%
% This is also a fairly rigorous test of whether or not a cell responds to
% a stimulus. If the cell is unresponsive, no bin will be significantly
% different from baseline and onset latency will be NaN. Works well even
% for sparsely firing cells (whereas nonparametric paired tests of
% post-pre lack sensitivity). If alpha is left empty, it will be
% automatically set to take into account the size of the response window
% and the binwidth (a correction for multiple comparisons of
% response bins to baseline).
%
% INPUTS
% CLUSTER: standard cluster file
% BASESTART: start of baseline (spontaneous) window (ms)
% BASEEND: end of baseline window (ms)
% STIMONSET: time of stimulus onset (ms) -- This only affects the absolute value
% of the latency reported and does not factor into the statistical test.
% WINSTART: start of window to begin looking for significant responses (ms)
% WINEND: end of window (ms)
% ALPHA: alpha value for determining what is a 'significant' response
% BINWIDTH: size of bins used in constructing PSTH (ms)
%
% OUTPUTS
% ONSET: onset latency of PSTH (ms), which should be equivalent to earliest onset for
% trials
% PEAK: modal latency of PSTH (ms)
%
% Randy Bruno, February 2004 - wrote original SpikeLatency.m
%
% January 2013: SpikeLatency2.m differs from SpikeLatency.m in that the
% input parameters now allow for changing the start/end of the baseline
% (spontaneous) window.

if nargin < 9
    PLOT = true;
end

if nargin < 8
    binwidth = 1;
end

if nargin < 6
    cluster = ReadCluster;
    basestart = 1;
    baseend = 144;
    stimOnset = 145;
    winstart = 149;
    winend = 200;
end

if isnan(cluster) | isempty(cluster)
    return
end

if nargin < 7 || isempty(alpha)
    alpha = 0.05 / round((winend-winstart) / binwidth);
    disp(['SpikeLatency2.m: alpha automatically set to ' num2str(alpha)]);
end

% because spike rates for cortical cells can be low, analysis is performed on PSTH
[n, x] = PSTH(cluster, winstart, winend, [], PLOT, winend, binwidth);

% remove normalization by ntrials (so we are dealing with absolute spike
% counts per bin)
ntrials = length(unique(cluster(:,2)));
n = n * ntrials;

% compute average spontaneous spikes per bin
spon = mean(n(x >= basestart & x <= baseend));

% given this number of spontaneous spikes, what number exceeds
% the alpha (is substantially different from spontaneous)?
crit = poissinv(1 - alpha, spon);
% note this is spikes/bin, not spikes/bin/trial

% If spon is 0, crit will be NaN. In this case, take the first spike as
% being the onset latency by setting crit to 0.
if isnan(crit)
    crit = 0;
end

% return onset latency, first bin exceeding the critical value (NaN if none)
sigbins = find(n > crit);
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
    hold on;
    line([1 winend], [crit/ntrials crit/ntrials], 'LineStyle', ':');
    title(['mean spontaneous spikes / stim / bin = ' num2str(spon / ntrials), ...
           ', mean spontaneous spikes / bin = ' num2str(spon), ...
           ', onset latency = ' num2str(signif(onset, 1))]);
end
