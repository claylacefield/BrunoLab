function P = Spec(x)

% WZ February 2008
%
% Given vector, return fft for frequencies >= 0.
% By definition, power for such an autospectrum can only be positive.

P = fft(x);

n = length(P);
n = ceil(n / 2);
P = P(1:n);
