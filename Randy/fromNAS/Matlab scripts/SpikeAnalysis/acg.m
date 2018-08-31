function lag = acg(cluster, LIMIT)

if nargin < 2
    LIMIT = 25;
end

maxtrial = max(cluster(:,2));

cluster = RemoveNullSpikes(cluster);
timestamp = cluster(:,4);
trial = cluster(:,2);
lag = [];
for i = 0:maxtrial
    x = timestamp(trial == i);
    y = repeach(x, length(x)) - repmat(x, length(x), 1);
    y = y(y > 0 & y <= LIMIT);
    lag = [lag; y];
end;

if ~isempty(lag)
    hist(lag, 10*max(lag));
    xlabel('lag (msec)');
    ylabel('n');
    axis([0 Inf -Inf Inf]);
    box off;
else
    axis([0 1 0 1]);
    title('no spike pairs');
end
