function [y] = BoxcarFilter(y, windowSize)

y = filter(ones(1, windowSize) / windowSize, 1, y);
