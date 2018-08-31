function [whiskBoutCaStruc] = calcItiWhiskCa(stimTrigTime, timeMs, wPkTimes, dendriteBehavStruc, v, ma, params)

% 
% This function was broken out of itiWhiskBoutCaFrame.m
% on 1/14/17 
% 

preBout = params.preBout;
postBout = params.postBout;

% extract frame ca signal and frame times
frameAvgDf = dendriteBehavStruc.frameAvgDf;
frameTrig = dendriteBehavStruc.eventStruc.frameTrig; 

% calculate ca frame rate
imRate = 1000/mean(diff(frameTrig));

if imRate > 4 && imRate < 8 
    fps = 8;
elseif imRate < 4 && imRate > 2
    fps = 4;
elseif imRate <2
    fps = 2;
else
    disp('Weird frame rate');
end


%% Concat wPkTimes before each clean stim ind
% (meaning no randRew before)
% Thus, we're looking in the ITIs BEFORE each stimTrigTime (2s-1s before)
currDir = dir;
binInd = find(cellfun(@length, strfind({currDir.name}, '.bin')));  % get dir indices of .txt files
binName = currDir(binInd).name;
x2 = binRead2pSingleName(binName);

[itiStruc] = findStimITIind(dendriteBehavStruc.eventStruc, x2);
itiBegTimes = itiStruc.itiBegTimes;
itiEndTimes = itiStruc.itiEndTimes;
clear x2;

whiskAirPks = [];
wPkTimes = wPkTimes';

% preBout = 1000; % 500;
% postBout = 2000;
% 
% whiskBoutCaStruc.params.preBout = preBout;
% whiskBoutCaStruc.params.postBout = postBout;

for trial = 1:length(stimTrigTime)
    %disp(trial);
    whiskAirPks = [whiskAirPks wPkTimes((wPkTimes>(itiBegTimes(trial)+preBout)) & (wPkTimes<(itiEndTimes(trial)-postBout)))];
end
%disp(whiskAirPks);
%% And extract avg Ca2+ triggered on these whisking bouts

%frameTrig = eventStruc.frameTrig;

eventTimes = whiskAirPks;
eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end)); % trim whisking events to time of calcium imaging

zeroFrame = [];
% after finding clean whisk bouts, find Ca frame nearest to event
for j=1:length(eventTimes)
    [offsetTime, nearestFrameInd] = min(abs(frameTrig - eventTimes(j)));
    zeroFrame(j) = nearestFrameInd;
    %zeroFrWhisk(j) = 
end

% now take Ca window around this time
%frameAvgDf = dendriteBehavStruc.frameAvgDf;
numFrames = length(frameAvgDf);

%fps = 4;    % NOTE that the actual frame rate is probably slightly less than this
preFrame = 2*fps;    % number of frames to take before and after event time
postFrame = 6*fps;

% then find indices of a window around the events
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

% and select out ca for that epoch
for k = 1:length(endFrame)
    % eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    try
    % for frame avg Ca signal
    eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    catch
        disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
    end
end

%% find whisk var for these

whBegFr = [];whEndFr = [];

% find wh frames near beg and end of Ca epochs
for numBout = 1:length(beginFrame)
    whBegFr(numBout) = find(timeMs > frameTrig(beginFrame(numBout)), 1);
    whEndFr(numBout) = find(timeMs > frameTrig(endFrame(numBout)), 1);
end

maxLen = max(whEndFr-whBegFr);  % find max wh bout length

itiWhiskBoutVar = zeros(maxLen, numBout);
itiWhiskBoutAngle = zeros(maxLen, numBout);

for numBout = 1:length(beginFrame)
    itiWhiskBoutVar(1:(whEndFr(numBout)-whBegFr(numBout)),numBout) = v(whBegFr(numBout):whEndFr(numBout)-1);
    itiWhiskBoutAngle(1:(whEndFr(numBout)-whBegFr(numBout)), numBout) = ma(whBegFr(numBout):whEndFr(numBout)-1);
    
    % fill in the padded values with mean
    itiWhiskBoutVar((whEndFr(numBout)-whBegFr(numBout))+1:end,numBout) = mean(v(whBegFr(numBout):whEndFr(numBout)-1));
    itiWhiskBoutAngle((whEndFr(numBout)-whBegFr(numBout))+1:end, numBout) = mean(ma(whBegFr(numBout):whEndFr(numBout)-1));
end


% for numBouts = 1:length(eventTimes)
%     
%    whiskFrInd = find(wPkTimes == eventTimes(numBouts)); % find frame of clean whisk bout
%    preBoutInds = wPks(whiskFrInd)-2*frRate;
%    postBoutInds = wPks(whiskFrInd)+6*frRate;
%    cleanItiWhiskBoutSig(:,numBouts) = rv(preBoutInds:postBoutInds);  % now take window around this
% end

% save relavant variables to output structure
whiskBoutCaStruc.itiWhiskBoutCa = eventCa;
whiskBoutCaStruc.itiWhiskBoutAngle = itiWhiskBoutAngle;
whiskBoutCaStruc.itiWhiskBoutVar = itiWhiskBoutVar;

% whiskBoutCaStruc.sessionName = sessionName;
% txtName = dendriteBehavStruc.eventStruc.correctRespStruc.name;
% whiskBoutCaStruc.txtName = txtName;
% whiskBoutCaStruc.lockout = lockout;
% whiskBoutCaStruc.sdThresh = sdThresh;
% 
% whiskBoutCaStruc.frameRate = frRate;


