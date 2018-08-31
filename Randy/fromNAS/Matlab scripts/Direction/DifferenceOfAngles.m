function d = DifferenceOfAngles(x, y, mustBeInSet)

% Given two angles x & y that belong to the set of 8 angles used for
% whisker stimulation, calculate the rotational difference from x to y
% (positive #'s mean y is counter clockwise of x, negative #'s mean y is
% clockwise of x)
%
% Randy Bruno, October 2004

if mustBeInSet
    if (sum(ismember([0:45:315], x)) == 0) | (sum(ismember([0:45:315], y)) == 0)
        error('DifferenceOfAngles requires that x & y be elements of [0 45 90 135 180 225 270 315]');
    end
end

d = abs(x - y);
if (d > 180)
    d = 360 - d;
end

if (y < x & y > x - 180) | (y > x + 180)
    d = -d;
end
