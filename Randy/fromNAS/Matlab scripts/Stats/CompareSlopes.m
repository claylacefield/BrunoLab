function [pval]= CompareSlopes(x1, y1, x2, y2, test)
%
% Compares slope parameters of linear regressions onto
% two different datasets. Uses formulas from Armitage, Berry & Matthews
% 2002 Statistical methods in medical research (4th ed.) Oxford: Blackwell
% Science.
%
% INPUTS
% x1, y1: dependent and independent values for 1st linear regression
% x2, y2: dependent and independent values for 2nd linear regression
% test: 'different', if hypothesis is slope1 doesn't equal slope2
%       'less', if hypothesis is slope1 < slope2
%       'greater', if hypothesis is slope1 > slope2
%
% OUPUTS p-value
%
% Randy Bruno & Elaine Zhang, July 2009

% determine sample sizes
n1 = length(x1);
n2 = length(x2);
df = n1 + n2 - 4;

% get slopes
fit1 = regstats(y1, x1, 'linear', {'beta', 'r'});
fit2 = regstats(y2, x2, 'linear', {'beta', 'r'});
slope1 = fit1.beta(2); % slope of fit1
slope2 = fit2.beta(2); % slope of fit2
SYY1 = sum((fit1.r).^2); % sum of squares of residuals for fit1
SYY2 = sum((fit2.r).^2); % sum of squares of residuals for fit2

% pooled estimate of the residual variance
s2r = (SYY1 + SYY2) / df;

% standard error of the difference of slopes
SXX1 = var(x1,1)*n1;
SXX2 = var(x2,1)*n2;
se = sqrt(s2r * (1/SXX1 + 1/SXX2));

% calculate t statistic
t = (slope1 - slope2) / se;

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

