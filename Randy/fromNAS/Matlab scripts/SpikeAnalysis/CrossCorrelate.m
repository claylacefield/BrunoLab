function [n, x] = CrossCorrelate(A, B, limit, binsize, norm)

% CCG(A, B, LIMIT, BINSIZE) crosscorrelates spikes from clusters A and B,
% where B is the trigger
% LIMIT is the maximum lag time between spikes to examine.
% BINSIZE is the bin size for lags in msecs.
% Randy Bruno, April 2003

switch nargin
    case 2
        limit = 1000;
        binsize = 1;
        norm = false;
    case 3
        binsize = 1;
        norm = false;
    case 4
        norm = false;
    case 5
    otherwise
        error('ccg: incorrect # of arguments')
end

trialA = A(:,2);
tsA = A(:,4);
trialB = B(:,2);
tsB = B(:,4);

lags = [];
for i = min(trialA):max(trialA)
    Ai = tsA(trialA == i);
    Bi = tsB(trialB == i);
    x = repeach(Ai, length(Bi)) - repmat(Bi, length(Ai), 1);
    x = x(abs(x) <= limit);
    lags = [lags; x];
end

if length(lags)==0
    warning('No spikes to crosscorrelate. Check selected trial numbers, start/end times, datafile, etc.');
end

x = -(limit-binsize/2):binsize:(limit-binsize/2);
n = hist(lags, x);

if norm
%     autoA = CrossCorrelate(A, A, limit, binsize, false);
%     autoB = CrossCorrelate(B, B, limit, binsize, false);
    figure;
    subplot(4,1,1);
    plot(x,n);
%     n = n ./ (sqrt(autoA .* autoB));
    n = n / length(tsA) / length(tsB);
    disp(['sum of n = ' num2str(sum(n))])
    subplot(4,1,2);
    plot(x,n);
%     subplot(4,1,3);
%     plot(x,autoA);
%     subplot(4,1,4);
%     plot(x,autoB);
end
disp(size(n))

