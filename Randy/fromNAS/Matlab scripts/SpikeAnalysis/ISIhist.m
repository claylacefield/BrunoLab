function ISIs = ISIhist(cluster, PLOT)

% ISIHIST Plots an ISI histogram.

if nargin < 2
    PLOT = true;
end

cluster = RemoveNullSpikes(cluster);
ISIs = ISIof(cluster);
i = isnan(ISIs);
i = i(i==0);

if PLOT
    if length(i) > 0
        hist(ISIs, 10*max(ISIs));  
        xlabel('interspike interval (msec)');
        ylabel('n');
        set(gca, 'XScale', 'log');
        axis([0 Inf -Inf Inf]);
        box off;
    else
        axis([0 1 0 1]);
        title('no ISIs');
    end
end
