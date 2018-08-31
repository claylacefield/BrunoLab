function [times, frRate] = calcWhiskFrameTimes(totalFr, rewStimAdjTime, rewStimFrames, sessInd)

% USAGE: [times] = calcWhiskFrameTimes(totalFrNum, rewStimAdjTime, rewStimFrames);
% align whisker video frame times with LabView based upon stim movement
% times

%totalFrNum = ;

% time rew stim stops moving
startTime1 = rewStimAdjTime(1);
startTime2 = rewStimAdjTime(2);

% frames rew stim stops moving
rewStimFr1 = rewStimFrames(sessInd,1);
rewStimFr2 = rewStimFrames(sessInd,2);

% empirical frame rate
empMsFr = (startTime2-startTime1)/(rewStimFr2-rewStimFr1); % *1000;  % fr/ms
frRate = 300;
%frTime = round(1/frRate);
frTimeMs = 1/frRate*1000;
frTimeMs = empMsFr;

% find time of first frame
t0 = startTime1-(rewStimFr1-1)*frTimeMs;
%t0 = startTime1-(rewStimFr1-1)*empMsFr;

% now fill in all times based upon framerate
%times = t0:frTime:(totalFrNum*frTime+t0);
times = round(t0:frTimeMs:((double(totalFr)-1)*frTimeMs+t0));

% (rewStimFr1-1)*frRate
% 
% preFrameTimes = startTime1:-frRate:




