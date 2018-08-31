function P = CrossSpec(X, Y)

% RMB & WZ February 2008
%
% Given two vectors, return cross-spectrum for frequencies >= 0.
% Cross-spectrum power can be - or + values.

fx = fft(X);
fy = fft(Y);
P = fx .* conj(fy);

n = length(P);
n = ceil(n / 2);
P = P(1:n);