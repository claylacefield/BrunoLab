function [ dendriteBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, hz, avg, roi)

% Master script for looking at behavior-triggered average calcium signals

%% NOTE:
% Can make this script a lot shorter by indexing the structures and looping
% through the different event type times instead of specifying each one
% independently
% Can read out structure field names with:
% fn = fieldnames(eventStruc);
% for m = 1:length(fn)
%   eventTimes = eventStruc.(fn{m});  % reads the fieldname in list
%   outputStruc.([fn{m} 'Avg']) = eventTimes;  % and writes to field in list
% end
%



%% Import the image stack

frameNum = 0;

% if nargin < 1
[filename pathname] = uigetfile('*.tif', 'Select a multi-page TIFF to read');
filepath = [pathname filename];
% end

% see how big the image stack is
stackInfo = imfinfo(filepath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;

for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;
    %imwrite(frame*10, 'outfile.tif')
end

tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)

numFrames = sizeStack;

%% Calculate ROI profiles
% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity
% NOTE: select all ROIs first, then whole frame avg

% avg = 1; roi = 1; % specify wheter to process frame mean profile and ROI profiles
[roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);

if avg == 0 
        frameAvg = mean(mean(tifStack,1),2);  % take average for each frame
        frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
        % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
        
        MyFilt=fir1(100,[0.02 0.9]);    % I just set the range empirically
        filtFrameAvg = filtfilt(MyFilt,1,frameAvg);
        
        frameAvgDf = (filtFrameAvg - mean(filtFrameAvg,1))/(mean(filtFrameAvg, 1));
        
end
    

%% Detect behavioral event times from BIN file and event type indices from TXT
% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

[eventStruc] = detect2pEvents(nChannels,1000);


% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

frameTrig = eventStruc.frameTrig;
stimTrig = eventStruc.stimTrig;

corrRewInd = eventStruc.corrRewInd;
incorrRewInd = eventStruc.incorrRewInd;
corrUnrewInd = eventStruc.corrUnrewInd;
incorrUnrewInd = eventStruc.incorrUnrewInd;

corrRewStimTimes = stimTrig(corrRewInd);
incorrRewStimTimes = stimTrig(incorrRewInd);
corrUnrewStimTimes = stimTrig(corrUnrewInd);
incorrUnrewStimTimes = stimTrig(incorrUnrewInd);

firstContactTimes = eventStruc.firstContactTimes;
corrFirstContactTimes = eventStruc.corrFirstContactTimes;
incorrFirstContactTimes = eventStruc.incorrFirstContactTimes;

rewardTimes = eventStruc.rewards;
lickTimes = eventStruc.licks;
punTimes = eventStruc.punTime;

levPress = eventStruc.levPress;
levLift = eventStruc.levLift;

preFrame = 2*hz;
postFrame = 6*hz;



%% Correct rewarded stimuli

for j=1:length(corrRewStimTimes)
    zeroFrame(j) = find(frameTrig >= corrRewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    corrRewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

corrRewCaAvg = mean(corrRewCa, 2);

dendriteBehavStruc.corrRewCa  =  corrRewCa;
dendriteBehavStruc.corrRewCaAvg  =  corrRewCaAvg;

figure; plot(corrRewCaAvg); hold on;
title('correct and incorrect rewarded trial whole frame Ca avgs');

%% Incorrect rewarded stimuli

for j=1:length(incorrRewStimTimes)
    zeroFrame(j) = find(frameTrig >= incorrRewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 1:length(endFrame)
    
    incorrRewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(incorrRewCa(:,k), 'r');
    
end

incorrRewCaAvg = mean(incorrRewCa, 2);

dendriteBehavStruc.incorrRewCa  =  incorrRewCa;
dendriteBehavStruc.incorrRewCaAvg  =  incorrRewCaAvg;

plot(incorrRewCaAvg, 'r'); hold off;

%% Correct unrewarded stimuli

for j=1:length(corrUnrewStimTimes)
    zeroFrame(j) = find(frameTrig >= corrUnrewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 1:length(endFrame)
    
    corrUnrewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrUnrewCa(:,k));
    
end

corrUnrewCaAvg = mean(corrUnrewCa, 2);

dendriteBehavStruc.corrUnrewCa  =  corrUnrewCa;
dendriteBehavStruc.corrUnrewCaAvg  =  corrUnrewCaAvg;

figure; plot(corrUnrewCaAvg); hold on;
title('correct and incorrect unrewarded trial whole frame Ca avgs');


%% Incorrect unrewarded stimuli

for j=1:length(incorrUnrewStimTimes)
    zeroFrame(j) = find(frameTrig >= incorrUnrewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    incorrUnrewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(incorrUnrewCa(:,k), 'r');
    
end

incorrUnrewCaAvg = mean(incorrUnrewCa, 2);

dendriteBehavStruc.incorrUnrewCa  =  incorrUnrewCa;
dendriteBehavStruc.incorrUnrewCaAvg  =  incorrUnrewCaAvg;

plot(incorrUnrewCaAvg, 'r'); hold off;

%% Correct first contacts

for j=1:length(corrFirstContactTimes)
    zeroFrame(j) = find(frameTrig >= corrFirstContactTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    corrFirstContactCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    if roi == 1
        for roiNum = 1:length(roiStruc)
            roiDf = roiStruc(roiNum).roiDf;
            ROIcorrFirstContactCa (:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
            
        end
    end
    
end

if roi == 1
    ROIcorrFirstContactCaAvg = mean(ROIcorrFirstContactCa,3);
    ROIcorrFirstContactCaAvgAvg = mean(ROIcorrFirstContactCaAvg,2);
end

corrFirstContactCaAvg = mean(corrFirstContactCa, 2);

dendriteBehavStruc.corrFirstContactCa  =  corrFirstContactCa;
dendriteBehavStruc.corrFirstContactCaAvg  =  corrFirstContactCaAvg;

figure; plot(corrFirstContactCaAvg); hold on;
title('correct and incorrect first whisker contact whole frame Ca avgs');

%% Incorrect first contacts

incorrFirstContactTimes = incorrFirstContactTimes(find(incorrFirstContactTimes ~= 0));

for j=1:length(incorrFirstContactTimes)
    zeroFrame(j) = find(frameTrig >= incorrFirstContactTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    incorrFirstContactCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    if roi == 1
        for roiNum = 1:length(roiStruc)
            roiDf = roiStruc(roiNum).roiDf;
            ROIincorrFirstContactCa (:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));            
        end
    end
    
end

if roi == 1
    ROIincorrFirstContactCaAvg = mean(ROIincorrFirstContactCa,3);
    ROIincorrFirstContactCaAvgAvg = mean(ROIincorrFirstContactCaAvg,2);
end

incorrFirstContactCaAvg = mean(incorrFirstContactCa, 2);

dendriteBehavStruc.incorrFirstContactCa  =  incorrFirstContactCa;
dendriteBehavStruc.incorrFirstContactCaAvg  =  incorrFirstContactCaAvg;%% Correct first contacts


plot(incorrFirstContactCaAvg, 'r'); hold off;

%% all first contacts

for j=1:length(firstContactTimes)
    zeroFrame(j) = find(frameTrig >= firstContactTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    firstContactCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

firstContactCaAvg = mean(firstContactCa, 2);

dendriteBehavStruc.firstContactCa  =  firstContactCa;
dendriteBehavStruc.firstContactCaAvg  =  firstContactCaAvg;


%% all rewards

for j=1:length(rewardTimes)
    zeroFrame(j) = find(frameTrig >= rewardTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    rewardCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    rewTif(:,:,1:(preFrame + postFrame +1),k) = tifStack(:,:,beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

rewTifAvg = uint16(mean(rewTif, 4));

% rewTifAvgDf = rewTifAvg.-tifAvg;

for i = 1:size(rewTifAvg, 3) 
    rewTifAvgDf = rewTifAvg(:,:,i)-tifAvg;
    imwrite(rewTifAvg(:,:,i), 'rewTifAvg.tif', 'writemode', 'append'); 
end

rewardCaAvg = mean(rewardCa, 2);

dendriteBehavStruc.rewardCa  =  rewardCa;
dendriteBehavStruc.rewardCaAvg  =  rewardCaAvg;

figure; plot(rewardCaAvg); hold on;
title('reward, punishment, and lick whole frame Ca avgs');

%% all punishments

for j=1:(length(punTimes)-1)
    zeroFrame(j) = find(frameTrig >= punTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 2:length(endFrame)
    
    punCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

punCaAvg = mean(punCa, 2);

dendriteBehavStruc.punCa  =  punCa;
dendriteBehavStruc.punCaAvg  =  punCaAvg;

plot(punCaAvg, 'r');

%% all licks

for j=1:(length(lickTimes)-1)
    zeroFrame(j) = find(frameTrig >= lickTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 6:(length(endFrame)-2)
    
    lickCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

lickCaAvg = mean(lickCa, 2);

dendriteBehavStruc.lickCa  =  lickCa;
dendriteBehavStruc.lickCaAvg  =  lickCaAvg;

plot(lickCaAvg, 'g'); hold off;

%% lever presses

for j=1:length(levPress)
    zeroFrame(j) = find(frameTrig >= levPress(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 3:(length(endFrame)-2)
    
    levPressCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

levPressCaAvg = mean(levPressCa, 2);

dendriteBehavStruc.levPressCa  =  levPressCa;
dendriteBehavStruc.levPressCaAvg  =  levPressCaAvg;

figure; plot(levPressCaAvg); hold on;
title('lever presses and lifts Ca Avg');

%% lever lifts

for j=1:length(levLift)
    zeroFrame(j) = find(frameTrig >= levLift(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 3:(length(endFrame)-2)
    
    levLiftCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
    
    %plot(corrRewCa(:,k));
    
end

levLiftCaAvg = mean(levLiftCa, 2);

dendriteBehavStruc.levLiftCa  =  levLiftCa;
dendriteBehavStruc.levLiftCaAvg  =  levLiftCaAvg;

plot(levLiftCaAvg, 'g'); hold off;

%%
% So, what else do I need to make?
% - look at averages for:
% - all stim
% - 
% - 
%
%
