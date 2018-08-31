function [y] = abx2Function(p, x);

% p: parameters
%       1) a
%       2) b

a = p(1);
b = p(2);

y = a + b*x.^2;
