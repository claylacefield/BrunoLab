function ProportionPlot(successes, attempts)

% Plots proportions on a bar chart and automatically computes/plots 95% CI
% based on a binomial distribution.
%
% Randy Bruno, April 2005
%
% INPUTS
% successes: array in which each element specifies # of successes for some
% category
% attempts: array in which each element specifies # of corresponding
% attempts for that category

if length(successes) ~= length(attempts)
    error('length of successes and attempts must match');
end

[p, pci] = binofit(successes, attempts);
disp(p)
disp(pci)
ll = (pci(:,1)' - p)*100;
ul = (pci(:,2)' - p)*100;
p = p*100;

bar(1:length(p), p, 'w');
hold on;
errorbar(1:length(p), p, ll, ul, 'LineStyle', 'none', 'Color', 'k');
hold off;
box off;
ylim([0 100]);

for i = 1:length(ul)
    text(i, p(i) + ul(i) + 10, [num2str(successes(i)) '/' num2str(attempts(i))], 'HorizontalAlignment', 'center');
    text(i, p(i) + ul(i) + 5, ['(' num2str(round(p(i))) '%)'], 'HorizontalAlignment', 'center');
end
