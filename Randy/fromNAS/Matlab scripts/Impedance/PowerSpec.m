function P = PowerSpec(x)

% RMB & WZ February 2008
%
% Given vector, return power spectrum for frequencies >= 0.
% By definition, power for such an autospectrum can only be positive.

f = fft(x);
P = f .* conj(f);

n = length(P);
n = ceil(n / 2);
P = P(1:n);
