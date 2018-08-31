function [coeffs] = FitExp(x, y, PLOT)

% fit an exponential
% Randy Bruno, Sep 2014

if nargin < 3
    PLOT=false;
end

if ncols(x) > 1
    x = x';
end
if ncols(y) > 1
    y = y';
end

f = fit(x,y,'exp1');
coeffs = coeffvalues(f);
% first coeff is initial value
% second coeff is decay constant

