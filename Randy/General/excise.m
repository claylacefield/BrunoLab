function X = excise(X)

% EXCISE(X) removes NaNs from X

X = X(~isnan(X));
