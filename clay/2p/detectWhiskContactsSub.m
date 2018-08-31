function [whiskContacts] = detectWhiskContactsSub(whiskSig)

% NOTE 021817: not currently used, in favor of findWhiskSigContactsSub.m


% whiskSig1 = whiskSig1-mean(whiskSig1);

% stdWhisk = std(whiskSig1);

% filter whisker signal
% Nyquist = 2*sf;
%MyFilt1=fir1(100,[10 200]/Nyquist);  % [10 200]
%filtWhiskSig1 = filtfilt(MyFilt1,1,whiskSig1);
% filtWhiskSig1 = filtfilt(MyFilt1,1,double(whiskSig1));
% filtWhiskSig1 = filtWhiskSig1 - runmean(filtWhiskSig1, 200);

filtWhiskSig = whiskSig - runmean(whiskSig, 20);  % 071913: now subtracting running mean instead of filtering

timeoutMs = 10;  % how many ms minimum between whisk touches
timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh = 4*std(filtWhiskSig)+0.4;  % stdev threshold for whisker touch detection
    
whiskContacts = LocalMinima(-filtWhiskSig, timeoutSamp, -stdThresh);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));








