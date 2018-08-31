function [itiWhiskBoutCaStruc] = itiWhiskBoutCaFrame(toSave, toPlot) % dendriteBehavStruc, frameAvgDf, meanAngle, times)

%% USAGE: [eventCa, v, wPks] = itiWhiskBoutCaFrame(dendriteBehavStruc, frameAvgDf, mean_angle, times)

% So this is just reconstructed from the command history when I was trying
% to extract whisking bout-triggered calcium during "clean" ITIs


%% Load in all necessary structures in session directory
sessionDir = dir;

sessionDirNames = {sessionDir.name};

whiskDataStrucName = sessionDir(find(cellfun(@length, strfind(sessionDirNames, 'whiskDataStruc')))).name;
load(whiskDataStrucName);

sessionName = whiskDataStrucName(1:14);

dbsInd = find(cellfun(@length, strfind(sessionDirNames, 'dendriteBehavStruc')));
dbsDatenums = [sessionDir(dbsInd).datenum];
[lsaMax, lastInd] = max(dbsDatenums);
latestDbsInd = dbsInd(lastInd);
load(sessionDir(latestDbsInd).name);

% and load in the variables
frameAvgDf = dendriteBehavStruc.frameAvgDf;
meanAngle = whiskDataStruc.meanAngle; 
times = whiskDataStruc.frTimes;

frRate = whiskDataStruc.frameRate;
meanAngle = meanAngle(2:end);  % trim first point



% find end of calcium imaging session
eventStruc = dendriteBehavStruc.eventStruc;
frameTrig = eventStruc.frameTrig;
lastFrameTrigTime = frameTrig(end) + 500;

%%
% correcting in case video went longer than LabView (like 2014-09-13-001)
%t = 1:size(x2, 2);  % length in ms of entire session (LabView sigs)
%timeMs = (time*1000);   % make whisk vid frame times in ms
timeMs = times;
tWhiskVidFrames = timeMs(timeMs < lastFrameTrigTime);  % cut off extra frame times
ma = meanAngle(1:length(tWhiskVidFrames));     % and whisk vid frames

%rma = runmean(ma, 10);

%figure; plot(ma); hold on; plot(rma, 'g');

%% Detect whisking bouts

%ma = mean_angle;
%frameTimes = times;
%frameRate = 300;

% moving variance of mean whisker angle
% using MATLABexchange function
v = movingvar(ma', 50);
% v=v';
% sv = std(v);
% sdThresh = 2; % 2; pre 030515 = 1
% lockout = 300; % frameRate;  pre 030515 = 100
% wPks = LocalMinima(-v, lockout, -sdThresh*sv); % detect peaks
% NOTE: these are pk ind of whisker video frame times

rv = runmean(v, 100); 
lockout = 1000; sdThresh = 2;
wPks = threshold(rv, sdThresh*std(rv), lockout);

%% Find clean ITI/stimTimes
% load in the relevant variables from calcium structure
%eventStruc = dendriteBehavStruc.eventStruc;
stimTrigTime = eventStruc.stimTrigTime;
rewTime4 = eventStruc.rewTime4; % random reward times

% look for indices of stimTrigTimes right after random rewards
%stimAfterRand = knnsearch(stimTrigTime, rewTime4); % these are stims beside (i.e. just after) random rewards
for numRew = 1:length(rewTime4)
    try
   stimAfterRand(numRew) = find(stimTrigTime>rewTime4(numRew),1); 
    catch
    end
end

cleanItiInd = setxor(stimAfterRand, 1:length(stimTrigTime)); % these are ones that are not

% load in stimTrigTime to find times of clean stims
%cleanItiInd = [];
%stimTrigTime = eventStruc.stimTrigTime;
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
eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end)); % trim whisking events to time of calcium imaging


% after finding clean whisk bouts, find Ca frame nearest to event
for j=1:length(eventTimes)
    [offsetTime, nearestFrameInd] = min(abs(frameTrig - eventTimes(j)));
    zeroFrame(j) = nearestFrameInd;
    %zeroFrWhisk(j) = 
end

% now take Ca window around this time
%frameAvgDf = dendriteBehavStruc.frameAvgDf;
numFrames = length(frameAvgDf);

fps = 4;    % NOTE that the actual frame rate is probably slightly less than this
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
    try
    % for frame avg Ca signal
    eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
        
    catch
        disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
        
    end
    
end

%% find whisk var for these

for numBout = 1:length(begFrame)
    whBegFr(numBout) = find(timeMs > frTrig(begFrame(numBout)), 1);
    whEndFr(numBout) = find(timeMs > frTrig(endFrame(numBout)), 1);
    cleanItiWhiskBoutSig(numBout,:) = rv(whBegFr(numBout):whEndFr(numBout));
end

cleanItiWhiskBoutSig

for numBouts = 1:length(eventTimes)
    
   whiskFrInd = find(wPkTimes == eventTimes(numBouts)); % find frame of clean whisk bout
   preBoutInds = wPks(whiskFrInd)-2*frRate;
   postBoutInds = wPks(whiskFrInd)+6*frRate;
   cleanItiWhiskBoutSig(:,numBouts) = rv(preBoutInds:postBoutInds);  % now take window around this
end

% save relavant variables to output structure
itiWhiskBoutCaStruc.itiWhiskBoutCa = eventCa;
itiWhiskBoutCaStruc.itiWhiskBoutAngle = cleanItiWhiskBoutSig;

itiWhiskBoutCaStruc.sessionName = sessionName;
txtName = dendriteBehavStruc.eventStruc.correctRespStruc.name;
itiWhiskBoutCaStruc.txtName = txtName;
itiWhiskBoutCaStruc.lockout = lockout;
itiWhiskBoutCaStruc.sdThresh = sdThresh;

if toSave
save([sessionName '_itiWhiskBoutCaStruc_' date], 'itiWhiskBoutCaStruc');
end

% plot

eventWh = cleanItiWhiskBoutSig;
%eventWh = eventWh(1:10:end);
%eventWh = (eventWh-mean(eventWh))/std(eventWh);

if toPlot
% figure; plot(eventCa);
% title([txtName ' whisking bout triggered ca traces, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 
%figure; plot(mean(eventCa,2));
semCa = std(eventCa,0,2)/sqrt(size(eventCa,2));
semWh = std(eventWh,0,2)/sqrt(size(eventWh,2));
tCa = linspace(1,length(eventWh), length(eventCa));
figure; 
errorbar(mean(eventWh,2)/4000, semWh/4000, 'r'); hold on;
errorbar(tCa, mean(eventCa,2), semCa);
title([txtName ' mean whisking bout triggered avg, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 
end
