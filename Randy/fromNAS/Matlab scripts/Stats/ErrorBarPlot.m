function [means, errors, bins] = ErrorBarPlot(X, Y, binsize, linecolor)

% The built-in Matlab function errorbar requires that the means and
% standard errors have already been calculated. This function does that
% pre-processing.
%
% Randy Bruno, February 2006

if nargin < 2
    error('ErrorBarPlot requires at least X and Y inputs');
end
if nargin < 3
    bin = 1;
end
if nargin < 4
    linecolor = 'b';
end

means = [];
errors = [];

mn = floor(min(X) / binsize) * binsize;
mx = ceil(max(X) / binsize) * binsize;
bins = mn:binsize:mx;
halfbin = binsize / 2;

for i = bins
    means = [means; mean(Y(X >= i-halfbin & X < i+halfbin))];
    errors = [errors; stderr(Y(X >= i-halfbin & X < i+halfbin))];
end
errorbar(bins, means, errors, linecolor);
box off;
