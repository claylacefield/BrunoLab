function [p] = CompareVariances(x, y)
% [P] = COMPAREVARIANCES(X,Y)
% Compares the variances of two variables using an F test.
%
% Randy Bruno, April 2005

x = excise(x);
y = excise(y);

F = var(x) / var(y);
p = (1 - fcdf(F, length(x)-1, length(y)-1)) * 2;
