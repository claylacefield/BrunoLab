function [angle, magnitude, sumx, sumy] = meanVector(response, direction)

% Compute the average angle and magnitude of polar data
%
% IN:
% response: array of response magnitudes
% direction: array of corresponding identifying angles in degrees
%
% Randy Bruno, October 2004

% convert polar coordinates to Cartesian coordinates
[x, y] = pol2cart(DegreesToRadians(direction), response);

% sum x's & y's
sumx = sum(x);
sumy = sum(y);

% calculate mean vector in polar coordinates
angle = signif(RadiansToDegrees(atan2(sumy, sumx)), 0);
if (angle < 0)
    angle = angle + 360;
end
magnitude = sqrt(sumy^2 + sumx^2);
