function [x, y] = ExtractDataFromLine

% Extracts x-y values for a line in the most recently selected figure.
% Assumes the figure contains a single line.
%
% Randy Bruno, November 2010

h = findobj(gcf, 'Type', 'line');
x = get(h,'xdata');
y = get(h,'ydata');
