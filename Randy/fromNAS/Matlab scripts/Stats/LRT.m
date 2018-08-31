function [p] = LRT(data, fhandle1, fhandle2, params1, params2)

% Likelihood Ratio Test
%
% fhandle1, params1: the simple model
% fhandle2, params2: the complex model
%
% Randy Bruno, August 2009

n = length(data);

% Compute the ratio for each datapoint and then multiply.
% Helps prevent precision loss.
lambdas = nans(n,1);
for i = 1:n
    L1 = likelihood(data(i), fhandle1, params1{:});
    L2 = likelihood(data(i), fhandle2, params2{:});
    lambdas(i) = L1 / L2;
end
lambda = prod(lambdas);

statistic = -2 * log(lambda);
df = length(params2) - length(params1);
p = 1 - chi2cdf(statistic, df);
