function [tau, b] = Fitabx2(x, y, PLOT)

% fit a + bx^2
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

b = nlinfit(x, y, @abx2Function, [1 1], statset('FunValCheck', 'off'));

if PLOT
    figure;
    scatter(x, y);
    xx = linspace(min(x), max(x), 100);
    pred = abx2Function(b, xx);
    line(xx, pred);
end
