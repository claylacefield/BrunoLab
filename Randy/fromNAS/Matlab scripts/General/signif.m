function y = signif(x, digits)

% SIGNIF(X, DIGITS) Round X to DIGITS significant decimal places.
% Randy Bruno, October 2003

y = round(x * 10 ^ digits) / 10 ^ digits;
