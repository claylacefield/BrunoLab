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
    periON = frame(75:90);  % take only the period around the stimulus onset
    [maxONamp, maxONindRel] = min(periON);  % find the peak ON response amplitude (it's a negativity, so use MIN)
    maxONind(i) = maxONindRel(1) + 74;  % take absolute index for peak ON response
    %(doesn't work right now because there may be multiple occurences of
    %this amplitude, so I'm just taking the first one)
    relONmagSD(i) = (frameBase - maxONamp)/frameSDbase; % find the relative amplitude of the peak ON response
    relONmagAv(i) = (frameBase - maxONamp)/frameBase;
    meanBase(i) = frameBase;    % just record the baseline for each frame (for correlation with other stuff)
end
    
%%
% Now do stuff with the resulting info

% find the largest ON signals (vs. mean or SD) for all trials
[maxMagAv, maxAvInd] = max(relONmagAv);
[maxMagSD, maxSDind] = max(relONmagSD);

% plot stuff

% this plots the relative size of the ON response to see if there are
% systematic fluctuations in the size of the response over time (I haven't
% seen this to be the case thus far in my datasets)
figure; 
subplot(2,2,1); plot(relONmagSD); title('relative ON resp. amp. (SD)');

subplot(2,2,2); plot(spatMeanMat(:,maxSDind)); title('max relative ON resp. (SD)');

subplot(2,2,3); plot(relONmagAv); title('relative ON resp. amp. (mean)');

subplot(2,2,4); plot(spatMeanMat(:,maxAvInd)); title('max relative ON resp. (mean)');

% and just show the distribution of these amplitudes
figure; hist(relONmagSD);

