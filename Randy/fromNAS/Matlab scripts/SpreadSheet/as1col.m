function y = as1col(x)

[m, n] = size(x);

if m ~= 1 & n ~= 1
    disp(size(x));
    error('as1col is defined only for 1-D arrays');
end

if (m == 1)
    y = x';
else
    y = x;
end
