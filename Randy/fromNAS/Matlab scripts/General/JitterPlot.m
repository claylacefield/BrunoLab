function JitterPlot(varargin)

if nargin == 0
    error('JitterPlot requires at least 1 argument');
end

% figure;

for i = 1:length(varargin)
    y = excise(varargin{i});
    diff = length(varargin{i}) - length(y);
    if diff > 0
        warning(['removed ' num2str(diff) ' NAs']);
    end
    x = repmat(i, length(y), 1) + (rand(length(y), 1) - 0.5) / 3;
    scatter(x, y, 'MarkerEdgeColor', 'k');
    hold on;
    line([i-0.25 i+0.25], [median(y) median(y)], 'Color', 'k');
end
hold off;
xlim([0 length(varargin)+1]);
set(gca, 'XTick', 1:nargin);
