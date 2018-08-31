function Y = MeanSpec(X)

m = size(X);
n = m(3);
if n ~= max(m)
    error('3rd dimension is not largest dimension in MeanSpec.m');
end

Y = reshape(mean(X, 2), 1, n);