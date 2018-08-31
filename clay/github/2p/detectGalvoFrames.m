function [frameTrig] = detectGalvoFrames(galvoSig, fps)



%% Find frames (signal #7;   NOTE: this detects the ends of respective frames)

% galvoSig = x2(7,:);

frameTimeout = round(1/fps*1000-(200/fps));
galvoMin = min(galvoSig);

frameTrig = LocalMinima(galvoSig, frameTimeout, galvoMin/2); %+0.4);  % 05);
% Note: this works for 2Hz but need to check for 4Hz, and 
% for diff angle galvo signal

vStd = std(galvoSig(frameTrig));

frameTrig = LocalMinima(galvoSig, frameTimeout, galvoMin+10*vStd);



galvoAvMax = mean(galvoSig(frameTrig));
frameTrig = frameTrig(galvoSig(frameTrig)<(galvoAvMax + 0.4));  % 1));  % this cleans up frame trigger times to prevent mistakes
