function [dendriteBehavStruc, segStruc, frameAvgDf, eventStruc, x2] = dendriteBehavAnalysisSingleSeg(fps, toSave, toSeg) % nChannels, fps, avg, roi)

% [ dendriteBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, fps, avg, roi)
% Master script for looking at behavior-triggered average calcium signals

% nChannels = 8;
% fps = 4;
avg = 0;
roi = 0;



%% Import the image stack

frameNum = 0;

% if nargin < 1
[filename, pathname] = uigetfile('*.tif', 'Select a multi-page TIFF to read');
filepath = [pathname filename];
% end

cd(pathname);

currDir = dir;

fileInd = find(strcmp(filename, {currDir.name}));

tifDatenum = currDir(fileInd).datenum;  % use acq to find .bin and .txt files

% see how big the image stack is
stackInfo = imfinfo(filepath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
    
    cd('corrected');
    frame2 = imread(filename, 'tif', i);
    tifStack2(:,:,frameNum) = frame2;
    cd ..;
    
end

tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)

numFrames = sizeStack;

%% Calculate ROI profiles
% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity
% NOTE: select all ROIs first, then whole frame avg

% avg = 1; roi = 1; % specify wheter to process frame mean profile and ROI profiles

if avg == 1 || roi == 1
    [roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);
end

if avg == 0
    frameAvg = mean(mean(tifStack,1),2);  % take average for each frame
    frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
    % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
    
    % now doing this with the running mean (runmean from Matlab
    % Cntrl)
    
    runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
    
    frameAvgDf = (frameAvg - runAvg)./runAvg;
    
    % figure; plot(frameAvgDf);
end

%% and find segStruc

% if seg == 1
%     
%     basename = filename(1:(strfind(filename, '.tif')-1));
%     cd([dayPath basename]);
%     
tifDir = dir;

if toSeg

    prevSeg = 0;
    
    for d = 3:length(tifDir)
        if (~isempty(strfind(tifDir(d).name, 'seg')) && prevSeg == 0)
            disp(['loading in first segmented file: ' tifDir(d).name]);
            load(tifDir(d).name);
            C = segStruc.C;
            prevSeg = 1;
        end
    end
    
    if prevSeg == 0
        disp(['nmf segmentation for ' filename]);
        %                     basename = filename(1:(strfind(filename, '.tif')-1));
        
        try
            cd([dayPath basename '/corrected']);
            tic;
            K = 50;
            beta = 0.99;
            plotSeg = 0;
            segStruc = nmfBatch(filename, K, beta, plotSeg);
            C = segStruc.C;
            toc;
        catch
            disp(['Segmentation of ' filename ' failed']);
            C = [];
        end
        
    end
    
    if ~isempty(C)
        
        roiPkArr = [];
        roiPkIndCell= {};
        roiPkAmp = {};
        roiPkRate = [];
        
        for roiNum = 1:size(C,2)
            
            roiDf = C(:,roiNum);
            roiPks = zeros(size(C,1),1);
            
            try
                % now make hist of Ca2+ pks
                roiSd = std(roiDf);
                roiThresh = max(2*roiSd, 0.1);
                %             roiThresh = 0.04;
                %             roiDf = runmean([0; diff(roiDf)],2);
                
                %             roiPkInd = LocalMinima(-roiDf, 4, -roiThresh);    % indices of Ca2+ pks
                
                
                roiPkInd = threshold([0; diff(roiDf)], roiSd, fps);
                
                roiPkAmp{roiNum} = roiDf(roiPkInd);     % amp of detected pks
                roiPks(roiPkInd) = 1;
                roiPkArr(:,roiNum) = roiPks;
                roiPkIndCell{roiNum} = roiPkInd;
                roiPkRate(roiNum) = length(roiPkInd)/length(roiDf);
                
            catch   % must try/catch for segments that are 0 (not sure why)
                disp('WARNING: could not make histograms of ca events');
                roiPkAmp{roiNum} = [];
                roiPkArr(:,roiNum) = roiPks;
                roiPkIndCell{roiNum} = [];
                roiPkRate(roiNum) = 0;
            end
            
            clear roiPkInd roiPks;
            
        end
        
        segStruc.roiPkArr = roiPkArr;
        segStruc.roiPkIndCell = roiPkIndCell;
        segStruc.roiPkAmp = roiPkAmp;
        segStruc.roiPkRate = roiPkRate;
    end
    
    
else
    C = [];
end


%% Now just selecting TIF above and reading off corresponding behav file, etc. 
% from dataFileArray list


% filename = filename(1:(strfind(filename, '.tif')+3));

% rowInd = find(strcmp(filename, dataFileArray(:,1)));
% 
% if isempty(rowInd)
%     filename2 = [filename ''''];
%     rowInd = find(strcmp(filename2, dataFileArray(:,1)));
% end

cd('..');  % go back up from TIF directory to where other files are

% fps = dataFileArray{rowInd, 6};
% whiskSigType = dataFileArray{rowInd, 16};
% nChannels = dataFileArray{rowInd, 7};


%% Detect behavioral event times from BIN file and event type indices from TXT
% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

% if strcmp(whiskSigType, 'beam')
% [eventStruc, x2] = detect2pEventsBatch(dataFileArray, rowInd); %nChannels,1000);  % detect2pEvents(nChannels, sf);
% elseif strcmp(whiskSigType, 'video')
%     
%     [eventStruc, whiskSig1, x2] = detect2pEventsVidBatch(dataFileArray, rowInd);
% end

[eventStruc, x2] = detect2pEventsSingle(tifDatenum, fps); %nChannels,1000);  % detect2pEvents(nChannels, sf);

dendriteBehavStruc.eventStruc = eventStruc;

% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

% go ahead and unpack these because we're going to use it many times
frameTrig = eventStruc.frameTrig;
stimTrig = eventStruc.stimTrigTime;

fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names

preFrame = 2*fps;    % number of frames to take before and after event time
postFrame = 6*fps;

hz = fps;

% this loop unpacks all the structure fields into variables of the same name
for field = 1:length(fieldNames)
    
    if ~isempty(eventStruc.(fieldNames{field}))
        
        %disp(['Processing event-trig signal for: ' fieldNames{field}]);
        
        % don't process stimTrig, frameTrig, and firstContactAbsT
        if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
            
            eventName = genvarname(fieldNames{field});
            
            % now construct the names of the event ca signals
            eventNameCa = [eventName 'Ca'];
            eventNameCaAvg = [eventName 'CaAvg'];
            
            %if toSeg
            eventNameRoiHist = [eventName 'RoiHist'];
            eventNameRoiHist2 = [eventName 'RoiHist2'];
            %end
            
            eventNameFrInds = [eventName 'FrInds'];
            
            % if these are indices of trials, find corresponding times
            if strfind(fieldNames{field}, 'StimInd')
                eventTimes = stimTrig(eventStruc.(fieldNames{field}));
            elseif strfind(fieldNames{field}, 'Time')
                eventTimes = eventStruc.(fieldNames{field});
%             else eventTimes = 0;
            end
            
            try
            eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end));
            
            % eventEpochTool; % use subfunction to calculate event-trig Ca activ
            
            for j=1:length(eventTimes)
               [offsetTime, nearestFrameInd] = min(abs(frameTrig - eventTimes(j)));
                zeroFrame(j) = nearestFrameInd;
            end
            
%             for j=1:length(eventTimes)
%                 zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
%             end
            
            % then find indices of a window around the event
            beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
            okInd = find(beginFrame >= 0 & beginFrame < (numFrames-8*hz));  % make sure indices are all positive
            beginFrame = beginFrame(okInd); % and only take these
            zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
            
            endFrame = zeroFrame + postFrame;
            okInd2 = find(endFrame >= 8*hz & endFrame < numFrames); %
            endFrame = endFrame(okInd2);
            zeroFrame = zeroFrame(okInd2);   % just keep updated zeroFrames list for good measure
            beginFrame = beginFrame(okInd2);
            eventCa = []; segEventCa = []; roiEventMat = [];
            
            for k = 1:length(endFrame)
                
                % eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
                
                try
                    % for frame avg Ca signal
                    eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
                    
                    % find event-triggered Ca of segmented
                    % ROIs, if present
                    if ~isempty(C)
                        for roiNum = 1:size(C,2)
                            roiDf = C(:,roiNum);
                            segEventCa(:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
                            
                            % now make hist of Ca2+ pks
                            roiPkSess = roiPkArr(:,roiNum);
                            roiEventMat(:,roiNum,k)= roiPkSess(beginFrame(k):endFrame(k));
                            
                            
                        end
                    else segEventCa = []; roiEventMat = [];
                    end
                    
                    %plot(corrRewCa(:,k));
                    
%                     % tifStack avg
                    if strcmp(eventName, 'rewStimStimInd')
                        rewStimTif(:,:,:,k) = tifStack2(:,:,(beginFrame(k):endFrame(k)));
                    elseif strcmp(eventName, 'unrewStimStimInd')
                        unrewStimTif(:,:,:,k) = tifStack2(:,:,(beginFrame(k):endFrame(k)));
                    end
                    
                    
                catch
                    disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
                end
                
            end
            
            
            eventCaAvg = mean(eventCa, 2);
            
            eventRoiHist = sum(roiEventMat,3);
            
            if ~isempty(C)
                segEventCaAvg = mean(segEventCa, 3);
                segStruc.(eventNameCa) = segEventCa;
                segStruc.(eventNameCaAvg) = segEventCaAvg;
                segStruc.hz = hz;
                segStruc.(eventNameRoiHist)= eventRoiHist;
            end
            
            
            
            %eval([eventName ' = eventStruc.(fieldNames{field})']);
            
%             eventNameCa = [eventName 'Ca'];
%             eventNameCaAvg = [eventName 'CaAvg'];
            
            dendriteBehavStruc.(eventNameCa) = eventCa;
            dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
            
            % 081114 record trigger frames
            % for each event type
            dendriteBehavStruc.(eventNameFrInds) = zeroFrame;
            
            clear zeroFrame eventCa eventCaAvg eventRoiHist;
            
            catch
            end
            
        end
        
    end
end

cd(pathname);

if toSave

try
rewStimTifAvg = uint16(squeeze(mean(rewStimTif, 4)));
unrewStimTifAvg = uint16(squeeze(mean(unrewStimTif, 4)));

if ~exist('rewStimTif.tif')
    for fr = 1:33
        imwrite(rewStimTifAvg(:,:,fr), 'rewStimTif.tif', 'writemode', 'append');
        imwrite(unrewStimTifAvg(:,:,fr), 'unrewStimTif.tif', 'writemode', 'append');
    end
end
catch
   disp('Could not write rewStimTif'); 
end
% dendriteBehavStruc.rewStimTifAvg = rewStimTifAvg;
% dendriteBehavStruc.unrewStimTifAvg = unrewStimTifAvg;
clear rewStimTif unrewStimTif rewStimTifAvg unrewStimTifAvg;
cd ..;

% now just save the output structure in this directory
fn = filename(1:(strfind(filename, '.tif')-1));

% now just save the output structure for this session in this directory

cd(pathname);

try
    save([fn '_seg_' date '.mat'], 'segStruc');
    %clear segStruc;
catch
    disp('no segStruc');
end

save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');

end

plotDendBehavAnal(dendriteBehavStruc, filename, fps);

% clear tifStack dendriteBehavStruc;

% hgsave([fn '.fig']);


