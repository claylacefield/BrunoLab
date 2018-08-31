function Y = repeach(X, n)

% assumes a vector in a single column
%
% REPEACH(X, N) Replicates N times each element in X.

Y = reshape(repmat(X, 1, n)', n*length(X), 1);
