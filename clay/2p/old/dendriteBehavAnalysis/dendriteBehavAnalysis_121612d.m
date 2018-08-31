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

if avg == 1 | roi == 1
[roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);
end

if avg == 0 
        frameAvg = mean(mean(tifStack,1),2);  % take average for each frame
        frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
        % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
        
        % can adjust baseline through filtering (but I don't think this
        % works so well)
        
%         MyFilt=fir1(100,[0.02 0.9]);    % I just set the range empirically
%         filtFrameAvg = filtfilt(MyFilt,1,frameAvg);
%         
%         frameAvgDf = (filtFrameAvg - mean(filtFrameAvg,1))/(mean(filtFrameAvg, 1));

        % but I don't think that this works because the filtering upsets
        % the deltaF/F calculation (i.e. should subtract running mean)
        
        
        % so now doing this with the running mean (runmean from Matlab
        % Cntrl)
        
        runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
        
        frameAvgDf = (frameAvg - runAvg)./runAvg;
        
        % figure; plot(frameAvgDf);
        
        
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




% corrRewStimTimes corrRewCa corrRewCaAvg
% incorrRewStimTimes incorrRewCa incorrRewCaAvg
% corrUnrewStimTimes corrUnrewCa
% incorrUnrewStimTimes incorrUnrewCa 
% corrFirstContactTimes corrFirstContactCa
% incorrFirstContactTimes incorrFirstContactCa
% firstContactTimes firstContactCa
% rewardTimes rewardCa
% punTimes punCa
% lickTimes lickCa
% levPress levPressCa
% levLift levLiftCa


%% Correct rewarded stimuli

% find the next frame indices after these behav events
% (Note: need to put in catch for lack of events and something to make sure
% that the wrong frames are not chosen in case I started the imaging after
% I turned the lever on, by accident)

% find the first frames following these events


%% Incorrect rewarded stimuli

%% Correct unrewarded stimuli

%% Incorrect unrewarded stimuli

%% Correct first contacts

%% Incorrect first contacts

%% all first contacts

%% all rewards

% for k = 2:length(endFrame)
%     
%     rewardCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
%     rewTif(:,:,1:(preFrame + postFrame +1),k) = tifStack(:,:,beginFrame(k):endFrame(k));
%     
%     %plot(corrRewCa(:,k));
%     
% end
% 
% rewTifAvg = uint16(mean(rewTif, 4));
% 
% % rewTifAvgDf = rewTifAvg.-tifAvg;
% 
% for i = 1:size(rewTifAvg, 3) 
%     rewTifAvgDf = rewTifAvg(:,:,i)-tifAvg;
%     imwrite(rewTifAvg(:,:,i), 'rewTifAvg.tif', 'writemode', 'append'); 
% end


%% all punishments

%% all licks

%% lever presses

%% lever lifts

%%
% So, what else do I need to make?
% - look at averages for:
% - all stim
% - 

    function eventEpochTool
        
        for j=1:length(eventTimes)
            zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
        end
        
        % then find indices of a window around the event
        beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
        okInd = find(beginFrame > 0 & beginFrame < numFrames);  % make sure indices are all positive
        beginFrame = beginFrame(okInd); % and only take these
        zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
        
        endFrame = zeroFrame + postFrame;
        okInd = find(endFrame > 0 & endFrame < numFrames); %
        endFrame = endFrame(okInd);
        zeroFrame = zeroFrame(okInd);   % just keep updated zeroFrames list for good measure
        
        for k = 1:length(endFrame)
            
            eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
            
            if roi == 1
                for roiNum = 1:length(roiStruc)
                    roiDf = roiStruc(roiNum).roiDf;
                    ROIcorrFirstContactCa (:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
                    
                end
            end
            
            %plot(corrRewCa(:,k));
            
        end
        
        eventCaAvg = mean(corrRewCa, 2);
        
        if roi == 1
            ROIcorrFirstContactCaAvg = mean(ROIcorrFirstContactCa,3);
            ROIcorrFirstContactCaAvgAvg = mean(ROIcorrFirstContactCaAvg,2);
        end
        
        
        
        dendriteBehavStruc.corrRewCa  =  corrRewCa;
        dendriteBehavStruc.corrRewCaAvg  =  corrRewCaAvg;
        
        figure; plot(corrRewCaAvg); hold on;
        title('correct and incorrect rewarded trial whole frame Ca avgs');
        
        
        
    end

end
