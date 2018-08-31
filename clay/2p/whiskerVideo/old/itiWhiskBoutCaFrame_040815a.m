function [eventCa, v, wPks] = itiWhiskBoutCaFrame(dendriteBehavStruc, mean_angle, time)

% So this is just reconstructed from the command history when I was trying
% to extract whisking bout-triggered calcium during "clean" ITIs

eventStruc = dendriteBehavStruc.eventStruc;
frameTrig = eventStruc.frameTrig;
lastFrameTrigTime = frameTrig(end) + 500;

%%
% correcting in case video went longer than LabView (like 2014-09-13-001)
%t = 1:size(x2, 2);  % length in ms of entire session (LabView sigs)
timeMs = (time*1000);   % make whisk vid frame times in ms
tWhiskVidFrames = timeMs(timeMs < lastFrameTrigTime);  % cut off extra frame times
ma = mean_angle(1:length(tWhiskVidFrames));     % and whisk vid frames

%% Detect whisking bouts

%ma = mean_angle;
%frameTimes = times;
frameRate = 300;

% moving variance of mean whisker angle
% using MATLABexchange function
v = movingvar(ma', 50);
v=v';
sv = std(v);
sdThresh = 2; % 2; pre 030515 = 1
lockout = 300; % frameRate;  pre 030515 = 100
wPks = LocalMinima(-v, lockout, -sdThresh*sv); % detect peaks
% NOTE: these are pk ind of whisker video frame times


%% Find clean ITI/stimTimes
% load in the relevant variables from calcium structure
%eventStruc = dendriteBehavStruc.eventStruc;
stimTrigTime = eventStruc.stimTrigTime;
rewTime4 = eventStruc.rewTime4;

% look for indices of stimTrigTimes right after random rewards
stimAfterRand = knnsearch(stimTrigTime, rewTime4); % these are stims beside (i.e. just after) random rewards

cleanItiInd = setxor(stimAfterRand, 1:length(stimTrigTime)); % these are ones that are not

% load in stimTrigTime to find times of clean stims
%cleanItiInd = [];
stimTrigTime = eventStruc.stimTrigTime;
cleanStimTrigTime = stimTrigTime(cleanItiInd);


%% Now find whisking bouts during clean ITIs

% these are the times of whisking bout peaks
wPkTimes = tWhiskVidFrames(wPks);

whiskAirPks = [];

% concat wPkTimes in the 3s before each clean stim ind
% (meaning no randRew before)
for trial = 1:length(cleanStimTrigTime)
    whiskAirPks = [whiskAirPks wPkTimes((wPkTimes<(cleanStimTrigTime(trial)-1000)) & (wPkTimes>(cleanStimTrigTime(trial)-2000)))];
end

%% And extract avg Ca2+ triggered on these whisking bouts

%frameTrig = eventStruc.frameTrig;

eventTimes = whiskAirPks;
eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end));

% find Ca frame nearest to event
for j=1:length(eventTimes)
    [offsetTime, nearestFrameInd] = min(abs(frameTrig - eventTimes(j)));
    zeroFrame(j) = nearestFrameInd;
end

% now take Ca window around this time
frameAvgDf = dendriteBehavStruc.frameAvgDf;
numFrames = length(frameAvgDf);

fps = 4;
preFrame = 2*fps;    % number of frames to take before and after event time
postFrame = 6*fps;

% then find indices of a window around the event
beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
okInd = find(beginFrame >= 0 & beginFrame < (numFrames-8*fps));  % make sure indices are all positive
beginFrame = beginFrame(okInd); % and only take these
zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
endFrame = zeroFrame + postFrame;
okInd2 = find(endFrame >= 8*fps & endFrame < numFrames); %
endFrame = endFrame(okInd2);
zeroFrame = zeroFrame(okInd2);   % just keep updated zeroFrames list for good measure
beginFrame = beginFrame(okInd2);
eventCa = []; 

for k = 1:length(endFrame)
    % eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    %try
    % for frame avg Ca signal
    eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
        
    catch
        disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
        
    end
    
end

figure; plot(eventCa);
title(['whisking bout triggered ca traces, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 
%figure; plot(mean(eventCa,2));
sem = std(eventCa')/sqrt(size(eventCa,2));
figure; errorbar(mean(eventCa,2), sem);
title(['mean whisking bout triggered avg, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 

