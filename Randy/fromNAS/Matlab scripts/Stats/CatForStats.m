function x = CatForStats(varargin)

% find the largest array
n = 0;
for i = 1:nargin
    n = max([n, length(varargin{i})]);
end

% pad the arrays and concatenate them into x
x = zeros(n, nargin);
for i = 1:nargin
    x(:, i) = [varargin{i}; repmat(NaN, n - length(varargin{i}), 1)];
end
