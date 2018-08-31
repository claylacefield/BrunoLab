% Works on the output from linescan FFT to find certain information about 
% ANNINE VSD signals, namely:
% 1.) how big is the ON response for individual trials of whisker
% stimulation
% 2.) which trials have the largest ON response
%
% By doing so, I will later try to see which factors of the prestimulus
% signal correlate with the amplitude of response (since some trials
% produce really large responses while others show no apparent response).
% Other things I want to include later:
% 1.) correlate size of response with spectral characteristics of
% prestimulus period (i.e. gamma, etc.)
% 2.) do same with absolute amplitude of fluorescence
% 3.) cross correlate raw fluorescence pattern to see if higher signal
% frames are more correlated in raw form (outside of stimulus period) than
% with low signal frames (therefore movement may be a problem)



%%

for i = 1:400;
    frame = spatMeanMat(:,i);   % read off a spatial average from a single trial (across all points in linescan)
    frameBase = mean(frame(1:60), 1); % find the mean baseline for the spatial average (i.e. before whisker stimulus onset)
    frameSDbase = std(frame(1:60), 1); % calculate SD of this baseline period
    periON = frame(75:90);  % check the period 
    maxONamp = min(periON);  % find the peak ON response amplitude
    maxONindRel= find(frame(75:90) == maxONamp);  % find index of peak response
    %maxONind(i) = maxONindRel + 74;  % find index of peak response
    relONmag(i) = (frameBase - maxONamp)/frameSDbase; % find the relative amplitude of the peak ON response
    meanBase(i) = frameBase;
end
    
%%
