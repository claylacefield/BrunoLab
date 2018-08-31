function [y] = smooth(y, bandwidth)

y = conv(y, gausswin(bandwidth)) / bandwidth * 2;
y = y((floor(bandwidth/2 + 1)) : (end + 1 - ceil(bandwidth/2)));
