function  dendriteBehavAnalysisMouseSeg2sima(dataFileArray, seg, saveTif, filterDate)

% USAGE: dendriteBehavAnalysis(dataFileArray, seg, saveTif)
% Master script for looking at behavior-triggered average calcium signals

% output: batchDendStruc2fps, batchDendStruc4fps
% and dendriteBehavStruc in each session folder

% "Cage" for all files for a cage present in dataFileArray
% "Seg2" for also analyzing event-triggered timecourses of
%       segmented data (with new segmentation, seg2)
% "sima" because motion correction folder structure was from
%       later correction with SIMA

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the dendriteBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse

% NOTE: that really the only reason to use the dataFileArray is
% for getting the imaging rate, and also to see if the behav program
% is stage1b.
%
% Change Notes:
% 050415: putting in errorCell to compile possible errors, and adding in
% filterDate argument to select out particular segmentation dates for
% analysis

toPlot = 0;

mouseFolder = uigetdir;      % select the cage folder to analyze


% mouseName = cageDir(mouse).name;      % select the animal folder to analyze
cd(mouseFolder);
%[pathname animalName] = fileparts(mouseFolder);
mouseDir = dir;


num2hzFiles = 0;
num4hzFiles = 0;
num8hzFiles = 0;

tic;

%   % to find indices of a particular animal
%   arrLog = strcmp('W10', dataFileArray);  % gives logical array
%   rowInd = find(arrLog(:,2));     % find row indices where animal found
%   % OR
%   rowInd = find(strcmp('W10', {dataFileArray{:,2}}));
%   % which is the same as
%   rowInd = find(strcmp('W10', dataFileArray(:,2)));


for a = 3:length(mouseDir) % for each day of imaging in this animal's dir
    
    if mouseDir(a).isdir
        
        dayPath = [mouseFolder '/' mouseDir(a).name '/'];
        
        cd(dayPath); % go to this day of imaging
        
        dayDir = dir;
        
        for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
            if dayDir(b).isdir
                %% NEED TO ADD NEW LEVEL FOR TIF IN FOLDER FOR MOTION CORRECTION
                
                % see if this file is on the dataFileArray TIF list (and if so, what
                % row?)
                filename = [dayDir(b).name '.tif'];
                
                filename = filename(1:(strfind(filename, '.tif')+3));
                
                rowInd = find(strcmp(filename, dataFileArray(:,1)));
                
                if isempty(rowInd)
                    filename2 = [filename ''''];
                    rowInd = find(strcmp(filename2, dataFileArray(:,1)));
                end
                
                % if it is in list, then process data
                
                if rowInd
                    try
                        %                 cd(dayDir(b).name);  % NO, stay in the day folder
                        %                 % tif directory
                        
                        disp(['Processing ' filename]);
                        
                        %% Detect behavioral event times from BIN file and event type indices from TXT
                        % select behavior signal BIN file and behavior event TXT file
                        % and extract times of particular events
                        
                        disp('Detecting behavioral events');
                        tic;
                        
                        cd(dayPath);
                        
                        errorNum = 0;
                        errorCell = {};
                        
                        dendriteBehavStruc.filename = filename;
                        
                        %                             try  % with CATCH around 467
                        
                        % use special script for stage1b sessions
                        if strfind(dataFileArray{rowInd, 8}, 'stage')
                            
                            [eventStruc] = detect2pEventsBatchStage1(dataFileArray, rowInd);
                            stage1b = 1;
                        else
                            
                            [eventStruc] = detect2pEventsBatch(dataFileArray, rowInd);  % detect2pEvents(nChannels, sf);
                            
                            % go ahead and unpack these because we're going to use it many times
                            %                 frameTrig = eventStruc.frameTrig;
                            stimTrig = eventStruc.stimTrigTime;
                            stage1b = 0;
                            
                            % 082814 modifying eventStruc to include stim
                            % order variables
                            
                            [eventStruc] = findStimOrder(eventStruc);
                        end
                        
                        %dendriteBehavStruc.eventStruc = eventStruc;
                        
                        frameTrig = eventStruc.frameTrig; % unpack to trim frames if LabView stopped early
                        
                        toc;
                        
                        
                        %% Import the image stack
                        
                        frameNum = 0;
                        
                        cd([dayPath dayDir(b).name]);
                        
                        %filename = [dayDir(b).name '.tif'];
                        tifpath = [dayPath dayDir(b).name '/' filename]; %[dayDir(b).name '.tif']];
                        % NOTE: build the tifpath different because of the extra
                        % folder layer for motion correction
                        
                        disp(['Processing image stack for ' filename]);
                        tic;
                        
                        % see how big the image stack is
                        stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
                        sizeStack = length(stackInfo);  % no. frames in stack
                        width = stackInfo(1).Width; % width of the first frame (and all others)
                        height = stackInfo(1).Height;  % height of the first frame (and all others)
                        
                        clear stackInfo;    % clear this because it might be big
                        
                        % extract number of imaging channels and only take green for
                        % Ca++ activity
                        %                 numImCh = dataFileArray{rowInd, 11};
                        
                        % NOTE: took prev. out because manually removed other chan
                        numImCh = 1;
                        
                        % this is to preallocate tifstack for speed
                        numFrames = length(1:numImCh:sizeStack);
                        %tifStack = zeros(width, height, numFrames);
                        
                        % 051214: fix for bad frame initiation
                        % Because sometimes ScanImage balks when
                        % capturing the first few frames (reason
                        % unknown, but may be callback problem) yet
                        % there are still frameTrigs, so trim first few
                        % to size of tif stack (=numFrames)
                        
                        if length(frameTrig)>numFrames
                            frameTrig = frameTrig(((length(frameTrig)-numFrames)+1):end);
                            disp('More frameTrig than tif frames so cutting out first few galvo trigs...');
                            errorNum = errorNum + 1;
                            errorCell{errorNum} = 'More frameTrig than tif frames so cutting out first few galvo trigs...';
                        end
                        
                        eventStruc.frameTrig = frameTrig;
                        
                        dendriteBehavStruc.eventStruc = eventStruc;
                        
                        basename = filename(1:(strfind(filename, '.tif')-1));
                        
                        
                        
                        %saveTif = 1;
                        frameNum = 0;
                        
                        if saveTif
                            try
                                cd([basename '.sima']);
                                bname = [basename 'b.tif'];
                                firstFrame2 = imread(bname, 'tif', 1);
                                width2 = size(firstFrame2,1);
                                height2 = size(firstFrame2,2);
                                
                                tifStack2 = zeros(width2, height2, sizeStack);
                                
                                % now load all tifs in stack into 3D matrix
                                for i=1:numImCh:sizeStack
                                    %frame = imread(tifpath, 'tif', i); % open the TIF frame
                                    frameNum = frameNum + 1;
                                    tifStack2(:,:,frameNum) = imread(bname, 'tif', i);
                                end
                            catch
                                disp('Could not load sima corrected, so using original'); % so using original .tif');
                                cd([dayPath dayDir(b).name]);
                                tifStack = zeros(width, height, numFrames);
                                for i=1:numImCh:sizeStack
                                    frameNum = frameNum + 1;
                                    tifStack(:,:,frameNum) = imread(filename, 'tif', i);
                                end
                                tifStack2 = tifStack;
                            end
                            
                        else
                            tifStack = zeros(width, height, numFrames);
                            for i=1:numImCh:sizeStack
                                frameNum = frameNum + 1;
                                tifStack(:,:,frameNum) = imread(filename, 'tif', i);
                            end
                            tifStack2 = tifStack;
                        end
                        cd([dayPath dayDir(b).name]);
                        toc;
                        
                        
                        %tifStack = tifStack(:,:, 1:length(frameTrig));  % trim frames for which there is no LabView signal
                        
                        tifAvg = uint16(mean(tifStack2, 3)); % calculate the mean image (and convert to uint16)
                        
                        %numFrames = size(tifStack, 3);
                        
                        %% Calculate ROI profiles
                        % select ImageJ ROI Manager MultiMeasure TXT file
                        % and extract timecourses of calcium activity
                        % NOTE: select all ROIs first, then whole frame avg
                        
                        avg = 0; roi = 0; % specify wheter to process frame mean profile and ROI profiles
                        
                        %                 if avg == 1 || roi == 1
                        %                     [roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);
                        %                 end
                        
                        if avg == 0
                            frameAvg = mean(mean(tifStack2,1),2);  % take average for each frame
                            frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
                            % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
                            
                            % now doing this with the running mean (runmean from Matlab
                            % Cntrl)
                            
                            runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
                            
                            frameAvgDf = (frameAvg - runAvg)./runAvg;
                            
                            % figure; plot(frameAvgDf);
                        end
                        
                        %toc;
                        
                        if seg == 1
                            
                            basename = filename(1:(strfind(filename, '.tif')-1));
                            cd([dayPath basename]);
                            
                            tifDir = dir;
                            
                            prevSeg = 0;
                            
                            C = [];
                            
                            
                            % find tifDir indices of seg2 files
                            segInd = find(cellfun(@length, strfind({tifDir.name}, 'seg2')));
                            if filterDate ~= 0
                                filterInd = find(cellfun(@length, strfind({tifDir.name}, filterDate)));
                                segInd = intersect(segInd, filterInd);
                            end
                            
                            % find the latest seg2 file index
                            segDatenums = [tifDir(segInd).datenum];
                            [lsaMax, latSegArrInd] = max(segDatenums);
                            latestSegInd = segInd(latSegArrInd);
                            
                            
                            % load in this segStruc
                            %     for d = 3:length(tifDir)
                            %         if (~isempty(strfind(tifDir(d).name, 'seg')) && prevSeg == 0)
                            disp(['loading in previously segmented file: ' tifDir(latestSegInd).name]);
                            load(tifDir(latestSegInd).name);
                            C = segStruc.C;
                            prevSeg = 1;
                            
                            %                                 if prevSeg == 0
                            %                                     disp(['nmf segmentation for ' filename]);
                            %                                     %                     basename = filename(1:(strfind(filename, '.tif')-1));
                            %
                            %                                     try
                            %                                         cd([dayPath basename '/corrected']);
                            %                                         tic;
                            %                                         K = 50;
                            %                                         beta = 0.99;
                            %                                         plotSeg = 0;
                            %                                         segStruc = nmfBatch(filename, K, beta, plotSeg);
                            %                                         C = segStruc.C;
                            %                                         toc;
                            %                                     catch
                            %                                         disp(['Segmentation of ' filename ' failed']);
                            %                                         C = [];
                            %                                     end
                            %
                            %                                 end
                            
                        else
                            C = [];
                        end
                        
                        %% make histogram of Ca events for each seg
                        
                        fps = dataFileArray{rowInd, 6};
                        
                        if ~isempty(C)
                            
                            [segStruc] = detectAllSegPks(segStruc, fps);
                            
                        end
                        
                        %% And tabulate indices of behavioral event types
                        % (Extract values from behavioral event structure)
                        % find the times of frames and do timecourse average based upon those times
                        
                        disp('Calculating event-triggered frame Ca avg');
                        tic;
                        
                        
                        % put this in to limit frames to number of frame triggers
                        % from galvo (in case I stopped labview before scanimage)
                        % OR vice versa if there is an extra detected frame trigger
                        
                        if length(frameAvgDf) > length(frameTrig)
                            frameAvgDf = frameAvgDf(1:length(frameTrig));
                            if ~isempty(C)
                                C = C(1:length(frameTrig), :);
                            end
                            errorNum = errorNum + 1;
                            errorCell{errorNum} = 'More frames than frameTrig so trimming these off (labview stopped too early)';
                        elseif length(frameTrig) > length(frameAvgDf)
                            frameTrig = frameTrig(1:length(frameAvgDf));
                            errorNum = errorNum + 1;
                            errorCell{errorNum} = 'More frameTrig than frames, so trimming frameTrig (WARNING: might have dropped frames)';
                            % NOTE: may be better to adjust time another way
                            
                        end
                        
                        eventStruc.frameTrig = frameTrig;
                        dendriteBehavStruc.frameAvgDf = frameAvgDf;
                        dendriteBehavStruc.errorCell = errorCell;
                        
                        fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names
                        
                        %                             fps = dataFileArray{rowInd, 6};
                        %                             fps=fps;
                        
                        %                     preFrame = 2*fps;    % number of frames to take before and after event time
                        %                     postFrame = 6*fps;
                        
                        % this loop unpacks all the structure fields into variables of the same name
                        for field = 1:length(fieldNames)
                            
                            if ~isempty(eventStruc.(fieldNames{field}))
                                
                                % don't process stimTrig, frameTrig, and firstContactAbsT
                                if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
                                    
                                    eventName = genvarname(fieldNames{field});
                                    
                                    % now construct the names of the event ca signals
                                    eventNameCa = [eventName 'Ca'];
                                    eventNameCaAvg = [eventName 'CaAvg'];
                                    eventNameRoiHist = [eventName 'RoiHist'];
                                    eventNameRoiHist2 = [eventName 'RoiHist2'];
                                    
                                    eventNameFrInds = [eventName 'FrInds'];
                                    
                                    % try/catch in case problem with some event
                                    % types
                                    try
                                        %fps = fps;
                                        [zeroFrame, eventCa , eventCaAvg, segEventCa, eventRoiHist, eventRoiHist2] = eventTrigCaRoiPk(filename, eventStruc, fps, segStruc, frameAvgDf, field, tifStack2);
                                        
                                        if ~isempty(C)
                                            segEventCaAvg = mean(segEventCa, 3);
                                            segStruc.(eventNameCa) = segEventCa;
                                            segStruc.(eventNameCaAvg) = segEventCaAvg;
                                            segStruc.fps = fps;
                                            segStruc.(eventNameRoiHist)= eventRoiHist;
                                            segStruc.(eventNameRoiHist2)= eventRoiHist2;
                                        end
                                        
                                        
                                        %eval([eventName ' = eventStruc.(fieldNames{field})']);
                                        
                                        % and put into structure for this day
                                        dendriteBehavStruc.(eventNameCa) = eventCa;
                                        dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
                                        
                                        % 081114 record trigger frames
                                        % for each event type
                                        dendriteBehavStruc.(eventNameFrInds) = zeroFrame;
                                        
                                        % concatenate average into batch struc for each
                                        % framerate
                                        if fps == 2
                                            %                                 if num2fpsFiles == 0
                                            %                                     batchDendStruc2fps.(eventNameCaAvg) = [];
                                            %                                 end
                                            try
                                                batchDendStruc2hz.(eventNameCaAvg) = [batchDendStruc2hz.(eventNameCaAvg) eventCaAvg];
                                            catch
                                                batchDendStruc2hz.(eventNameCaAvg) = eventCaAvg;
                                            end
                                            %num2fpsFiles = num2fpsFiles + 1;
                                        elseif fps == 4
                                            %                                 if num4fpsFiles == 0
                                            %                                     batchDendStruc4fps.(eventNameCaAvg) = [];
                                            %                                 end
                                            
                                            try
                                                batchDendStruc4hz.(eventNameCaAvg) = [batchDendStruc4hz.(eventNameCaAvg) eventCaAvg];
                                            catch
                                                batchDendStruc4hz.(eventNameCaAvg) = eventCaAvg;
                                            end
                                            %num4fpsFiles = num4fpsFiles + 1;
                                        elseif fps == 8
                                            %                                 if num8fpsFiles == 0
                                            %                                     batchDendStruc8fps.(eventNameCaAvg) = [];
                                            %                                 end
                                            
                                            try
                                                batchDendStruc8hz.(eventNameCaAvg) = [batchDendStruc8hz.(eventNameCaAvg) eventCaAvg];
                                            catch
                                                batchDendStruc8hz.(eventNameCaAvg) = eventCaAvg;
                                            end
                                            %num8fpsFiles = num8fpsFiles + 1;
                                        end
                                        
                                        
                                        if saveTif == 1
                                            try
                                                
                                                %                     % tifStack avg
                                                if strcmp(eventName, 'rewStimStimInd') || strcmp(eventName, 'unrewStimStimInd')
                                                    disp(['Making avg TIF stack for ' eventName]); tic;
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
                                                    toc;
                                                end
                                            catch
                                                %disp('Could not process rewStimTif frame avg');
                                            end
                                        end
                                        
                                        
                                        clear zeroFrame eventCa eventCaAvg eventRoiHist eventRoiHist2;
                                        
                                    catch
                                        disp(['problem processing: ' eventName]);
                                        dendriteBehavStruc.(eventNameCa) = [];
                                        dendriteBehavStruc.(eventNameCaAvg) = [];
                                    end
                                end
                                
                            end     % end IF for ~isempty fieldname
                        end     % end FOR loop for all fieldnames
                        
                        % get tif file name
                        fn = filename(1:(strfind(filename, '.tif')-1));
                        
                        if saveTif
                            disp('Saving stim avg TIF stacks'); tic;
                            try
                                
                                if stage1b == 0
                                    rewStimTifAvg = uint16(squeeze(mean(rewStimTif, 4)));
                                    unrewStimTifAvg = uint16(squeeze(mean(unrewStimTif, 4)));
                                    %cd(tifPath);
                                    %                             if ~exist('rewStimTif.tif')
                                    for fr = 1:size(rewStimTifAvg, 3)
                                        imwrite(rewStimTifAvg(:,:,fr), [fn '_rewStimTif_' date '.tif'], 'writemode', 'append');
                                        imwrite(unrewStimTifAvg(:,:,fr), [fn '_unrewStimTif_' date '.tif'], 'writemode', 'append');
                                    end
                                    %                             end
                                end     % end IF for stage1b = 0
                                
                            catch
                                disp('WARNING: could not save rewStimTif');
                            end
                            toc;
                            %                             dendriteBehavStruc.rewStimTifAvg = rewStimTifAvg;
                            %                             dendriteBehavStruc.unrewStimTifAvg = unrewStimTifAvg;
                            clear rewStimTif unrewStimTif rewStimTifAvg unrewStimTifAvg; % tifStack2;
                            % cd ..;
                        end
                        
                        % and just save list of filenames in batch struc
                        if fps == 2
                            num2hzFiles = num2hzFiles + 1;
                            batchDendStruc2hz.name{num2hzFiles} = fn;
                        elseif fps == 4
                            num4hzFiles = num4hzFiles + 1;
                            batchDendStruc4hz.name{num4hzFiles} = fn;
                        elseif fps == 8
                            num8hzFiles = num8hzFiles + 1;
                            batchDendStruc8hz.name{num8hzFiles} = fn;
                        end
                        
                        
                        % now just save the output structure for this session in this directory
                        disp('Saving segStruc');
                        try
                            save([fn '_seg_' date '.mat'], 'segStruc');
                            clear segStruc;
                        catch
                            disp('no segStruc');
                        end
                        
                        save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');
                        
                        clear tifStack tifStack2; % dendriteBehavStruc;
                        
                        
                        
                        
                        %% plot output (and save graph)
                        
                        if toPlot
                            try
                                plotDendBehavAnal2(dendriteBehavStruc, fn, fps);
                                
                                hgsave([fn '_summGraphs_' date '.fig']);
                            catch
                                disp('cannot plot output graphs');
                            end
                        end
                        
                        toc;
                        
                        %                 catch
                        %                     disp(['Error analyzing ' filename ', skipping file']);
                        %                 end
                        
                        clear dendriteBehavStruc;
                        
                    catch
                        disp('Problem processing this file, so didnt save anything');
                    end
                    
                end  % END IF this TIF folder is in dataFileArray
            end % END IF this is a directory (dayDir(b).isdir)
        end % END FOR loop looking through all files in this day's folder (for this animal)
        
    end   % END if isdir in home folder
    
end  % END searching through all days in animal folder

cd(mouseFolder);

try
    save(['batchDendStruc2hz_' date], 'batchDendStruc2hz');
    clear batchDendStruc2hz;
catch
    disp('No 2hz files');
end

try
    save(['batchDendStruc4hz_' date], 'batchDendStruc4hz');
    clear batchDendStruc4hz;
catch
    disp('No 4hz files');
end

try
    save(['batchDendStruc8hz_' date], 'batchDendStruc8hz');
    clear batchDendStruc8hz;
catch
    disp('No 8hz files');
end

%clear batchDendStruc2fps batchDendStruc4fps batchDendStruc8fps;

toc;
