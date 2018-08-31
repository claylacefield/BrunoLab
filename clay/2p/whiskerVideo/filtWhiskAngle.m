function [s_filt] = filtWhiskAngle(ma, frRate);

% USAGE: [s_filt] = filtWhiskAngle(ma, frRate);
% Chebyshev filter of whisker signal from 0.1-0.8Hz
% for itiWhiskBout detection
%
% From: 
% https://www.mathworks.com/matlabcentral/answers/349832-how-to-apply-bandpass-filter

lo = 0.1;
hi = 0.8;


Fs = frRate;
Fn = round(Fs/2);
Wp = [lo hi]/Fn;
Ws = [lo-0.05 hi+0.05]/Fn;
Rp = 10;
Rs = 50;

[n,Ws] = cheb2ord(Wp, Ws, Rp, Rs);
[z,p,k] = cheby2(n,Rs,Ws);
[sosbp,gbp] = zp2sos(z,p,k);

s_filt = filtfilt(sosbp, gbp, ma);

% figure; 
% plot(2*(ma-mean(ma))/std(ma));
% hold on; plot(s_filt, 'g');
%plot(s_filt, 'r');
