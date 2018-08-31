function newavg = MemorylessAverage(oldavg, x, i)
% MEMORYLESSAVERAGE Compute an average without storing individual
% observations.
%
% MEMORYLESSAVERAGE(OLDAVG, X, I)
% OLDAVG: the last value of the running average
% X: the new item to be included in the average
% I: the non-zero-indexed element # of X
% Randy Bruno, May 2003

newavg = x/i + ((i-1) * oldavg / i);
