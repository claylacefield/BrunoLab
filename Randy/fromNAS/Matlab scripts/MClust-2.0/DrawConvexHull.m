function [x,y] = DrawConvexHull

% [x,y] = DrawConvexHull
% allows the user to draw a convex hull on the current axis
% and returns the x,y points on that hull
%
% ADR 1998
% Status PROMOTED
% version V4.1
%
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

[x,y] = ginput;
k = convexhull(x,y);
x = x(k);
y = y(k);