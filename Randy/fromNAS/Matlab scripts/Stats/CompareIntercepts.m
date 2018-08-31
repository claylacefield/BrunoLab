function [pval]= CompareIntercepts(x1, y1, x2, y2, test)
%
% Compares y-intercept parameters of linear regressions onto
% two different datasets. Equations from Karl L Weunsch. Assumes relatively
% similar variances. For greatly different variances, need alternative test
% (see Kleinbaum & Kupper 1978 Applied Regression Analysis and Other
% Multivariate Methods, pp.101-2).
%
% INPUTS
% x1, y1: dependent and independent values for 1st linear regression
% x2, y2: dependent and independent values for 2nd linear regression
% test: 'different', if hypothesis is slope1 doesn't equal slope2
%       'less', if hypothesis is slope1 < slope2
%       'greater', if hypothesis is slope1 > slope2
%
% OUTPUTS p-value
%
% Tested this program with testCompareIntercepts.m, which behaved correctly
% as slope, intercept, difference of intercepts, and noise were varied.
%
% Randy Bruno, July 2013

% determine sample sizes
n1 = length(x1);
n2 = length(x2);
df = n1 + n2 - 4;

% get y-intercepts
fit1 = regstats(y1, x1, 'linear', {'beta', 'r'});
fit2 = regstats(y2, x2, 'linear', {'beta', 'r'});
int1 = fit1.beta(1); % slope of fit1
int2 = fit2.beta(1); % slope of fit2

% pooled estimate of the residual variance
SYY1 = sum((fit1.r).^2); % sum of squares of residuals for fit1
SYY2 = sum((fit2.r).^2); % sum of squares of residuals for fit2
s2r = (SYY1 + SYY2) / df;

% standard error of the difference of intercepts
SXX1 = var(x1,1)*n1;
SXX2 = var(x2,1)*n2;
se = sqrt(s2r * (1/n1 + 1/n2 + mean(x1)^2/SXX1 + mean(x2)^2/SXX2));

% calculate t statistic
t = (int1 - int2) / se;

% calculate p-value
switch test
    case 'different'
        % test if slope1 and slope2 are different
        pval = 2 * cdf('t', -abs(t), df);
    case 'less'
        % test if slope1 < slope2
        pval = cdf('t', t, df);
    case 'greater'
        % test if slope1 > slope2
        pval = cdf('t', -t, df);
    otherwise
        error('not a valid test name');
end

