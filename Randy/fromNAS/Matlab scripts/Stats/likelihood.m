function [L] = likelihood(data, fhandle, varargin)

% Randy Bruno, August 2009

data = double(data);
l = fhandle(data, varargin{:});
l = double(l);
l = sort(l, 'descend');
L = prod(l);
