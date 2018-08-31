function [x] = nans(r, c)

x = zeros(r, c);
for i = 1:r
    for j = 1:c
        x(i, j) = NaN;
    end
end
