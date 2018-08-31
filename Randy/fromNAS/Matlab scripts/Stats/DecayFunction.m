function [y] = DecayFunction(b, x);

% b: parameters of the decay function
%       1) y0, the value to which the function decays in the limit
%       2) A, a scalar multiplier (amplitude)
%       3) invTau, 1/tau

y0 = b(1);
A = b(2);
invTau = b(3);

y = y0 + A * exp(-invTau * x);
