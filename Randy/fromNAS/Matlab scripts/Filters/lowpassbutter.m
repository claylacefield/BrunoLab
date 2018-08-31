function [y] = lowpassbutter(x, cutoff)

normCutoff = cutoff / (32000/2); % The cut-off frequency must be 0 < Wn < 1.0, where 1.0 is half the sample rate.
[b,a] = butter(4, normCutoff, 'low');
y = filter(b, a, x-mean(x));
y = y+mean(x);