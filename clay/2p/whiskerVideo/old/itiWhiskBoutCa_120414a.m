function [eventCa, segEventCa] = itiWhiskBoutCa(dendriteBehavStruc, segStruc, goodSeg, x2, mean_angle, time)

% So this is just reconstructed from the command history when I was trying
% to extract whisking bout-triggered calcium during "clean" ITIs

C = segStruc.C;
C = C(:, goodSeg);

%%
% correcting in case video went longer than LabView (like 2014-09-13-001)
t = 1:size(x2, 2);  % length in ms of entire session (LabView sigs)
timeMs = (time*1000);   % make whisk vid frame times in ms
tWhiskVidFrames = timeMs(timeMs < length(t));  % cut off extra frame times
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
wPks = LocalMinima(-v, 300, -2*sv); % detect peaks
% NOTE: these are pk ind of whisker video frame times


%% Find clean ITI/stimTimes
% load in the relevant variables from calcium structure
eventStruc = dendriteBehavStruc.eventStruc;
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

frameTrig = eventStruc.frameTrig;

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
eventCa = []; segEventCa = []; roiEventMat = [];

for k = 1:length(endFrame)
    % eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    %try
    % for frame avg Ca signal
    eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    try
        
        % find event-triggered Ca of segmented
        % ROIs, if present
        if ~isempty(C)
            for roiNum = 1:size(C,2)
                roiDf = C(:,roiNum);
                segEventCa(:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
                
                % now make hist of Ca2+ pks
%                 roiPkSess = roiPkArr(:,roiNum);
%                 roiEventMat(:,roiNum,k)= roiPkSess(beginFrame(k):endFrame(k));
%                 
            end
        else segEventCa = []; roiEventMat = [];
        end
        
    catch
        disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
        
    end
    
end

figure; plot(eventCa);
title('whisking bout triggered ca traces, lock=300,2sd'); 
%figure; plot(mean(eventCa,2));
sem = std(eventCa')/sqrt(size(eventCa,2));
figure; errorbar(mean(eventCa,2), sem);
title('mean whisking bout triggered avg, lock=300,2sd'); 

for i = 1:length(goodSeg)
    figure; 
    segCa = squeeze(segEventCa(:,i,:));
    sem = std(segCa')/sqrt(size(segCa,2));
    errorbar(mean(segCa,2), sem); 
    title(['seg = ' num2str(goodSeg(i)) ', lock=300,2sd']); 
end


% plot whisker moving var w. trials, frame and unit Ca,
% whisking and whisk peaks

t2 = tWhiskVidFrames;

figure;  
plot(frameTrig, C(:,goodSeg)*200, 'y'); 
hold on;
plot(t, x2(1,:)*40, 'm');
plot(t2, v);
plot(t2(wPks), v(wPks), 'r.');
plot(frameTrig, frameAvgDf*200, 'g');