function [y] = highpassfilter(x, cutoff)

normCutoff = cutoff / (32000/2); % The cut-off frequency must be 0 < Wn < 1.0, where 1.0 is half the sample rate.
b = fir1(8,normCutoff,'low');
b = firlp2hp(b)
y = conv(b,x);

