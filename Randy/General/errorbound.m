function hh = errorbound(varargin)
%ERRORBOUND Plots error bounds around a line (instead of error bars).
%
%   ERRORBOUND(Y, E) plots line using Y values and symmetric bounds at
%   Y +/- E. In this case, x-axis is simply a vector of length(Y).
% 
%   ERRORBOUND(X, Y, E) plots line along X,Y and symmetric bounds at Y +/-
%   E.
% 
%   ERRORBOUND(X, Y, L, U) plots line along X,Y and asymmetric bounds using
%   L and U. Note L and U are absolute values, not distances from Y.
%
% Randy Bruno, December 2014

switch nargin
    case 2
        y = varargin{1};
        x = 1:length(y);
        l = varargin{1}-varargin{2};
        u = varargin{1}+varargin{2};
    case 3
        x = varargin{1};
        y = varargin{2};
        l = varargin{2}-varargin{3};
        u = varargin{2}+varargin{3};
    case 4
        x = varargin{1};
        y = varargin{2};
        l = varargin{3};
        u = varargin{4};
    otherwise
        error('requires 2, 3 or 4 input arguments');
end

% ensure all data are in row format
x = reshape(x,length(x),1);
y = reshape(y,length(y),1);
l = reshape(l,length(l),1);
u = reshape(u,length(u),1);

% plot the line
plot(x, y, 'b');

% plot the error bounds
hold on;
h = fill([x; ReverseArray(x)], [l; ReverseArray(u)], 'b', 'EdgeColor', 'w');
set(h, 'FaceAlpha', 0.1);

hh = gcf;
