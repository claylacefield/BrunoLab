function [y] = thresholdlinearFunction(p, x);

% p: parameters
%       1) a = threshold
%       2) b = baseline
%       3) c = gain

disp(p);

pa = p(1);
pb = p(2);
pc = p(3);

y = pb + pc * (x - pa);
y(x < pa) = pb;
