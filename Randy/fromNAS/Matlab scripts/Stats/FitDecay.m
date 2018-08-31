function [tau, b] = FitDecay(x, y, PLOT)

% fit an exponential to decaying data
% Randy Bruno, Jan 2004

if nargin < 3
    PLOT=false;
end

if ncols(x) > 1
    x = x';
end
if ncols(y) > 1
    y = y';
end

b = nlinfit(x, y, @DecayFunction, [1 1 1], statset('FunValCheck', 'off'));
tau = 1/b(3);

if PLOT
    figure;
    scatter(x, y);
    xx = linspace(min(x), max(x), 100);
    pred = DecayFunction(b, xx);
    line(xx, pred);
end
