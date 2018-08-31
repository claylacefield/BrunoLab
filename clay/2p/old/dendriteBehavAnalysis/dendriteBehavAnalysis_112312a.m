function [ dendriteBehavStruc ] = dendriteBehavAnalysis()

% Master script for looking at behavior-triggered average calcium signals


% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity
% NOTE: select all ROIs first, then whole frame avg

[roiStruc, frameAvgDf] = dendriteProfiles();

% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

[eventStruc] = detect2pEvents();

% NOTE: need to finish correct/incorrect and estimation of punishment times
% from behavioral event TXT file





% find the times of frames and do timecourse average based upon those times


frameTrig = eventStruc.frameTrig;

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

preFrame = 4; 
postFrame = 10; 


%% Correct rewarded stimuli

for j=1:length(corrRewStimTimes)
    zeroFrame(j) = find(frameTrig >= corrRewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 1:length(endFrame)

corrRewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

%plot(corrRewCa(:,k));

end

corrRewCaAvg = mean(corrRewCa, 2);

dendriteBehavStruc.corrRewCa  =  corrRewCa;
dendriteBehavStruc.corrRewCaAvg  =  corrRewCaAvg;

%figure; plot(


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

%figure; plot(

%% Incorrect rewarded stimuli

for j=1:length(incorrRewStimTimes)
    zeroFrame(j) = find(frameTrig >= incorrRewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - 4;
endFrame = zeroFrame + 10;

for k = 1:length(endFrame)

incorrRewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

%plot(incorrRewCa(:,k), 'r');

end

incorrRewCaAvg = mean(incorrRewCa, 2);

dendriteBehavStruc.incorrRewCa  =  incorrRewCa;
dendriteBehavStruc.incorrRewCaAvg  =  incorrRewCaAvg;

%% Incorrect unrewarded stimuli

for j=1:length(incorrUnrewStimTimes)
    zeroFrame(j) = find(frameTrig >= incorrUnrewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - 4;
endFrame = zeroFrame + 10;

for k = 1:length(endFrame)

incorrUnrewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

%plot(incorrUnrewCa(:,k), 'r');

end

incorrUnrewCaAvg = mean(incorrUnrewCa, 2);

dendriteBehavStruc.incorrUnrewCa  =  incorrUnrewCa;
dendriteBehavStruc.incorrUnrewCaAvg  =  incorrUnrewCaAvg;

%% Import the image stack

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
    %imwrite(frame, 'outfile.tif')
end

%% Correct first contacts

for j=1:length(corrFirstContactTimes)
    zeroFrame(j) = find(frameTrig >= corrFirstContactTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 1:length(endFrame)

corrFirstContactCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

%plot(corrRewCa(:,k));

end

corrFirstContactCaAvg = mean(corrFirstContactCa, 2);

dendriteBehavStruc.corrFirstContactCa  =  corrFirstContactCa;
dendriteBehavStruc.corrFirstContactCaAvg  =  corrFirstContactCaAvg;

%% Incorrect first contacts

for j=1:length(incorrFirstContactTimes)
    zeroFrame(j) = find(frameTrig >= incorrFirstContactTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 1:length(endFrame)

incorrFirstContactCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

%plot(corrRewCa(:,k));

end

incorrFirstContactCaAvg = mean(incorrFirstContactCa, 2);

dendriteBehavStruc.incorrFirstContactCa  =  incorrFirstContactCa;
dendriteBehavStruc.incorrFirstContactCaAvg  =  incorrFirstContactCaAvg;%% Correct first contacts


%% all first contacts

for j=1:length(firstContactTimes)
    zeroFrame(j) = find(frameTrig >= firstContactTimes(j), 1, 'first');
end

beginFrame = zeroFrame - preFrame;
endFrame = zeroFrame + postFrame;

for k = 1:length(endFrame)

firstContactCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

%plot(corrRewCa(:,k));

end

corrFirstContactCaAvg = mean(firstContactCa, 2);

dendriteBehavStruc.firstContactCa  =  firstContactCa;
dendriteBehavStruc.firstContactCaAvg  =  firstContactCaAvg;


%%
% So, what else do I need to make?
% - look at averages for whisker touches 
% - 
%
%
%
%