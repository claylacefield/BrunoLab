function indices = threshold(x, level, lockout)

indices = [];
i = 2;
while i <= length(x)
    if (x(i) >= level & x(i-1) < level)
        indices = [indices; i];
        i = i + lockout;
    else
        i = i + 1;
    end
end
