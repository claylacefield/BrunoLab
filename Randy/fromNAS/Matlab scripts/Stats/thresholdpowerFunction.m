function [y] = thresholdpowerFunction(p, x);

% p: parameters
%       1) a = threshold
%       2) b = baseline
%       3) c = gain

%disp(['power ' num2str(p)]);

pa = p(1);
pb = p(2);
pc = p(3);
pd = p(4);

y = pb + pc * (x - pa).^pd;
y(x < pa) = pb;
