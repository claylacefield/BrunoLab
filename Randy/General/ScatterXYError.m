function ScatterXYError(x,y, scatterprop)
%
% Randy Bruno, October 2008
%

if nargin < 3
    scatter(x, y);
else
    scatter(x, y, scatterprop);
end
hold on;
mx = median(x);
my = median(y);
line([mx mx], prctile(y, [25 75]), 'Color', 'k');
line(prctile(x, [25 75]), [my my], 'Color', 'k');
