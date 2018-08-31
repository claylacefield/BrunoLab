%
% This script takes the output from Chris's whisker video analysis and does
% some post-processing (on mean whisker angle from whisker tracking)
% then detects whisking events
% THEN it finds wholeframe calcium triggered on these whisking bouts


% one-off correcting 2014-09-13-001
t = 1:size(x2, 2);  % length in ms of entire session (LabView sigs)
timeMs = (time*1000);   % make whisk vid frame times in ms
tWhiskVidFrames = timeMs(timeMs < length(t));  % cut off extra frame times  
ma = mean_angle(1:length(tWhiskVidFrames));     % and whisk vid frames

% moving variance of mean whisker angle
% using MATLABexchange function
v = movingvar(ma', 50); 
v=v';
sv = std(v);
wPks = LocalMinima(-v, 300, -sv); % NOTE: these are pk ind of whisker video frame times
eventTimes = tWhiskVidFrames(wPks);


%ma = mean_angle;
%frameTimes = times;
frameRate = 300;

% Detect whisking events
% ma2 = runmean(ma, 2);  % just smooth the whisker signal a little
% ma3 = ma2 - runmean(ma1, round(frameRate/30));  % subtract the low freq  component of the signal
% sma3 = std(ma3);  % take std for whisking event thresh
% wPks = LocalMinima(-ma3, round(frameRate/30), -sm3);  % detect whisking bouts
% eventTimes = time3(wPks);

% Get 2p frame info
frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
fps = 4;
numFrames = length(frameAvgDf);

% Then find the average Ca2+ triggered on these whisking events


eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end));

% eventEpochTool; % use subfunction to calculate event-trig Ca activ

for j=1:length(eventTimes)
    [offsetTime, nearestFrameInd] = min(abs(frameTrig - eventTimes(j)));
    zeroFrame(j) = nearestFrameInd;
end

%             for j=1:length(eventTimes)
%                 zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
%             end

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
    
%     try
%         
%         % find event-triggered Ca of segmented
%         % ROIs, if present
%         if ~isempty(C)
%             for roiNum = 1:size(C,2)
%                 roiDf = C(:,roiNum);
%                 segEventCa(:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
%                 
%                 % now make hist of Ca2+ pks
%                 roiPkSess = roiPkArr(:,roiNum);
%                 roiEventMat(:,roiNum,k)= roiPkSess(beginFrame(k):endFrame(k));
%                 
%                 
%             end
%         else segEventCa = []; roiEventMat = [];
%         end
%         
%         
%     catch
%         disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
%     end
    
end
