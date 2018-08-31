% This macro is for performing power analysis on proportions.
% Plots 95% CI and size of CI for different sample sizes under the
% assumption that the TrueProportion equals some constant.

TrueProp = 0.1;

n = 1:100;
lower = nans(length(n),1);
upper = nans(length(n),1);
for i=n
    [phat, pci] = binofit(TrueProp*i, i);
    lower(i) = pci(1);
    upper(i) = pci(2);
end
figure;
plot(n, lower);
hold on;
line(n, upper);
line(n, upper-lower, 'Color', 'r');
xlabel('sample size');
ylabel('proportion');

