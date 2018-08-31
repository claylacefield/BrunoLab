function boxplots(x, y)

% BOXPLOTS
%
% Deals with the nonsense of combining two variables into columns for
% boxplots because the Matlab programmers were too stupid to do it
% themselves... Do I sound angry?
%
% Randy Bruno, April 2005

n = max(length(x), length(y));
x = [x; repmat(NaN, n - length(x), 1)];
y = [y; repmat(NaN, n - length(y), 1)];
z = [x y];
boxplot(z);
