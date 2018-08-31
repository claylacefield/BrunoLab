function y = cell2num(x)

% Converts a cell array to a numeric array.
% Assumes data is 1-dimensional.
%
% Randy Bruno, October 2003

y = zeros(length(x), 1);
for (i = 1:length(x))
    if (strcmp(upper(x{i}), 'NA') | strcmp(upper(x{i}), 'NAN'))
        y(i) = NaN;
    else
        y(i) = x{i};
    end
end
