function [filtSig] = clayFilt(sig, sf, loHiCut)

fn = sf/2; % normalized frequency

ord = 48;

%omega = 2*pi*f/sf;

% filter signal (to get rid of stim artifacts, etc.)
myFilt=fir1(ord,[loHiCut(1)/fn, loHiCut(2)/fn]);
filtSig = filtfilt(myFilt,1,double(sig));

