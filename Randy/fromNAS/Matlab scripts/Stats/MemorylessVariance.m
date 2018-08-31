function newvar = MemorylessVariance(avg, oldvar, x, i)
% MEMORYLESSVARIANCE Compute a variance without having to load all the
% observations into memory simultaneously (see MEMORYLESSAVERAGE). Useful
% for extremely large datasets.
%
% MEMORYLESSVARIANCE(AVG, OLDVAR, X, I)
% AVG: the mean must have been pre-computed (i.e., via MEMORYLESSAVERAGE)
% OLDVAR: the last value (or vector) of the running variance
% X: the new item to be included in the variance
% I: the non-zero-indexed element # of X
%
% WARNING: When i is 1, the variance is incorrect. This value is used only
% to pass data into i > 1. The function assumes you will run for at least 2
% iterations.
%
% Randy Bruno, January 2013

switch i
    case 1
        newvar = abs(avg-x).^2;
    case 2
        newvar = (oldvar + abs(avg-x).^2);
    otherwise
        newvar = (oldvar * (i-2) + abs(avg-x).^2) / (i-1);
end
