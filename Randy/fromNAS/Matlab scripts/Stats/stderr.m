function s = stderr(X)

% S = STDERR(X) Calculates the standard error of X
%
% Randy Bruno, October 2004

X = excise(X);
s = std(X) / sqrt(length(X));
