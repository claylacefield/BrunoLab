function [c, lags] = normxcorr(x, y, maxlags)

switch nargin
    case 2
        [c,lags] = xcorr(x - mean(x), y-mean(y), 'coeff');
    case 3
        [c,lags] = xcorr(x - mean(x), y-mean(y), maxlags, 'coeff');
    otherwise
        disp('normxcorr.m error: incorrect number of arguments');
        c = NaN;
        lags = NaN;
end
