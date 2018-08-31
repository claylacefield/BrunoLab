function [b, bint, r, rint, stats] = linearAnalysis(y, x, plot)

% [b, bint, r, rint, stats] = linearAnalysis(y, x, plot)
%
% Performs a linear regression of predictor variable x and response
% variable y
%
% b: intercept and slope
% bint: 95% CI for b's
% r: residuals
% rint: 95% CI for each residual
% stats:    the R^2 statistic
%           the F statistic
%           a p value for the full model
%           an estimate of the error variance
% Randy Bruno, September 2003

if size(x,1)==1
    x = x';
end
if size(y,1)==1
    y = y';
end

xx = x(~isnan(x) & ~isnan(y));
yy = y(~isnan(x) & ~isnan(y));
x = xx;
y = yy;

X = [ones(length(x), 1) x]; % regress function requires a column of ones
[b, bint, r, rint, stats] = regress(y, X);

if plot
    xx = [min(x) max(x)];
    yy = xx*b(2) + b(1);
    line(xx, yy);
    
    disp(['R^2 (variance fraction) = ' num2str(stats(1)) ', r (correlation)  = ' num2str(sqrt(stats(1))) ', p = ' num2str(stats(3))]);
    s = regstats(y, x, 'linear', 'tstat');
    disp(['one-sided p-value = ' num2str(s.tstat.pval(2) / 2)]);
end