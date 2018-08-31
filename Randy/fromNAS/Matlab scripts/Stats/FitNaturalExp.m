function [tau, int] = FitNaturalExp(x, y, PLOT)

if nargin < 3
    PLOT=false
end

model = polyfit(x, log(y), 1);
tau = exp(model(1));
int = exp(model(2));
disp(['tau = ' num2str(tau) ', int = ' num2str(int)]);

if PLOT
    figure;
    plot(x, y);
    pred = log(polyval(model, x));
    line(x, pred, 'Color', 'r');
end

    