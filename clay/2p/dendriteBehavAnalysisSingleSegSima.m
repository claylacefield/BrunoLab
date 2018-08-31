function [dendriteBehavStruc, segStruc, frameAvgDf, eventStruc, x2] = dendriteBehavAnalysisSingleSegSima(fps, toSave, toSeg, filterDate) % nChannels, fps, avg, roi)

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

% Read in the frames for tifStack/frameAvgDf

disp(['Reading in TIF frames for ' filename]); tic;

%tifStack = zeros(width, height, sizeStack);
%tifStack2 = zeros(width, height, sizeStack);

for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
    
end
toc;


disp(['Reading in motion-corrected TIF frames for ' filename]); tic;

basename = filename(1:(strfind(filename, '.tif')-1));
cd([basename '.sima']);  % go to sima corrected folder

% see if tif tags already corrected (basename 'b.tif')
simaDir = dir;

simaFilenames = [simaDir.name]; % NOTE: that I'm intentionally concatenating all the filenames in this dir

% if isempty(strfind(simaFilenames, 'b.tif'))
%     
%     % have to correct tif tags if not already
%     disp('Correcting TIF tags');
%     correctMcTifTagBatch(filename);
% end

try
    for i = 1:sizeStack
        frame2 = imread(filename, 'tif', i);
        tifStack2(:,:,frameNum) = frame2;
    end
catch
    % have to correct tif tags if not already
    disp('Correcting TIF tags');
    correctMcTifTagBatch(filename);
    
    for i = 1:sizeStack
        frame2 = imread([basename 'b.tif'], 'tif', i);
        tifStack2(:,:,frameNum) = frame2;
    end
end
toc;
cd ..;

tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)

numFrames = sizeStack;

%% Calculate ROI profiles
% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity
% NOTE: select all ROIs first, then whole frame avg


%% Calculate frameAvgDf (from tifStack)
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

dendriteBehavStruc.frameAvgDf = frameAvgDf;



%% and find segStruc

% if seg == 1
%
%     basename = filename(1:(strfind(filename, '.tif')-1));
%     cd([dayPath basename]);
%
tifDir = dir;

if toSeg
    
    disp('Getting segStruc'); tic;
    
    prevSeg = 0;
    
    % find tifDir indices of seg2 files
    segInd = find(cellfun(@length, strfind({tifDir.name}, 'seg2')));
    
    if ~isempty(segInd)
        if filterDate ~= 0
            filterInd = find(cellfun(@length, strfind({tifDir.name}, filterDate)));
            latestSegInd = intersect(segInd, filterInd);
        else
            % find the latest seg2 file index
            segDatenums = [tifDir(segInd).datenum];
            [lsaMax, latSegArrInd] = max(segDatenums);
            latestSegInd = segInd(latSegArrInd);
        end
        
        disp(['loading in segmented file: ' tifDir(latestSegInd).name]);
        load(tifDir(latestSegInd).name);
        C = segStruc.C;
        prevSeg = 1;
        
    end
    

    % Segment if not already
    if prevSeg == 0
        disp(['nmf segmentation for ' filename]);
        %                     basename = filename(1:(strfind(filename, '.tif')-1));
        
        try
            cd([dayPath basename '/' basename '.sima']);
            tic;
            K = 100;
            beta = 0.5;
            plotSeg = 0;
            segStruc = nmfBatch(filename, K, beta, plotSeg);
            C = segStruc.C;
            toc;
        catch
            disp(['Segmentation of ' filename ' failed']);
            C = [];
        end
        
    end
    
    % now find all roi peaks/calcium events
    if ~isempty(C)
        [segStruc] = detectAllSegPks(segStruc, fps);
    end
    
else
    C = []; segStruc = [];
end
toc;

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
disp(['Detecting behavioral events for ' filename]); tic;
[eventStruc, x2] = detect2pEventsSingle(tifDatenum, fps); %nChannels,1000);  % detect2pEvents(nChannels, sf);

[eventStruc] = findStimOrder(eventStruc);

dendriteBehavStruc.eventStruc = eventStruc;

toc;

% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

disp(['Processing event-triggered frame and roi calcium for ' filename]); tic;

fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names

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
            
            try
                hz=fps;
                [zeroFrame, eventCa , eventCaAvg, segEventCa, eventRoiHist, eventRoiHist2] = eventTrigCaRoiPk(filename, eventStruc, hz, segStruc, frameAvgDf, field, tifStack2);
                
                if ~isempty(C)
                    segEventCaAvg = mean(segEventCa, 3);
                    segStruc.(eventNameCa) = segEventCa;
                    segStruc.(eventNameCaAvg) = segEventCaAvg;
                    segStruc.fps = fps;
                    segStruc.(eventNameRoiHist)= eventRoiHist;
                    segStruc.(eventNameRoiHist2)= eventRoiHist2;
                end
                
                %plot(corrRewCa(:,k));
                
                try
                    
                    %                     % tifStack avg
                    if strcmp(eventName, 'rewStimStimInd') || strcmp(eventName, 'unrewStimStimInd')
                        for numEvent = 1:length(zeroFrame)
                            frRange = (zeroFrame(numEvent)-2*fps):(zeroFrame(numEvent)+6*fps);
                            if strcmp(eventName, 'rewStimStimInd')
                                %disp('Compiling rewStimTif avg');
                                rewStimTif(:,:,:,numEvent) = tifStack2(:,:,frRange);
                            elseif strcmp(eventName, 'unrewStimStimInd')
                                %disp('Compiling unrewStimTif avg');
                                unrewStimTif(:,:,:,numEvent) = tifStack2(:,:,frRange);
                            end
                        end
                    end
                catch
                    disp('Could not process rewStimTif frame avg');
                end
                
            catch
                disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
            end
            
            dendriteBehavStruc.(eventNameCa) = eventCa;
            dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
            
            % 081114 record trigger frames
            % for each event type
            dendriteBehavStruc.(eventNameFrInds) = zeroFrame;
            
            clear zeroFrame eventCa eventCaAvg eventRoiHist;
            
        end  % end IF cond for stimInd or Times events
        
    end  % end IF cond for fieldnames with some data
    
end  % end FOR loop for all event types/fieldnames in eventStruc

toc;

cd(pathname);

if toSave
    disp('Saving output...'); tic;
    
    % now just save the output structure in this directory
    fn = filename(1:(strfind(filename, '.tif')-1));
    
    try
        disp('Writing rewStimTif stacks');
        rewStimTifAvg = uint16(squeeze(mean(rewStimTif, 4)));
        unrewStimTifAvg = uint16(squeeze(mean(unrewStimTif, 4)));
        
        %if ~exist('rewStimTif.tif')
        for fr = 1:size(rewStimTif, 3)
            imwrite(rewStimTifAvg(:,:,fr), [fn '_rewStimTif_' date '.tif'], 'writemode', 'append');
            imwrite(unrewStimTifAvg(:,:,fr), [fn '_unrewStimTif_' date '.tif'], 'writemode', 'append');
        end
        %end
    catch
        disp('Could not write rewStimTif');
    end
    % dendriteBehavStruc.rewStimTifAvg = rewStimTifAvg;
    % dendriteBehavStruc.unrewStimTifAvg = unrewStimTifAvg;
    clear rewStimTif unrewStimTif rewStimTifAvg unrewStimTifAvg;
    cd ..;
    
    
    
    % now just save the output structure for this session in this directory
    
    cd(pathname);
    
    if toSeg
        try
            save([fn '_seg_' date '.mat'], 'segStruc');
            %clear segStruc;
        catch
            disp('no segStruc');
        end
    end
    
    save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');
    toc;
end

plotDendBehavAnal2(dendriteBehavStruc, filename, fps);

% clear tifStack dendriteBehavStruc;

% hgsave([fn '.fig']);


