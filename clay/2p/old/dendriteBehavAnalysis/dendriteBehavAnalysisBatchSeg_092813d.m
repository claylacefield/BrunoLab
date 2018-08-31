function  dendriteBehavAnalysisBatchSeg(dataFileArray, seg)

% [ dendriteBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, hz, avg, roi)
% Master script for looking at behavior-triggered average calcium signals

% batchDendStruc2hz, batchDendStruc4hz

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the dendriteBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse


parentFolder = uigetdir;      % select the animal folder to analyze
cd(parentFolder);
%[pathname animalName] = fileparts(parentFolder);
parentDir = dir;

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


for a = 3:length(parentDir) % for each day of imaging in this animal's dir
    
    if parentDir(a).isdir
        
        dayPath = [parentFolder '/' parentDir(a).name '/'];
        
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
                
%                 cd(dayDir(b).name);  % NO, stay in the day folder
%                 % tif directory
                
                disp(['Processing ' filename]);
                
                %% Detect behavioral event times from BIN file and event type indices from TXT
                % select behavior signal BIN file and behavior event TXT file
                % and extract times of particular events
                
                disp('Detecting behavioral events');
                tic;
                
                %try
                
                cd(dayPath);
                
                [eventStruc] = detect2pEventsBatch(dataFileArray, rowInd);  % detect2pEvents(nChannels, sf);
                
                dendriteBehavStruc.eventStruc = eventStruc;
                
                frameTrig = eventStruc.frameTrig; % unpack to trim frames if LabView stopped early
                
                toc;
                
                
                %% Import the image stack
                
                frameNum = 0;
                
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
                numImCh = dataFileArray{rowInd, 11};
                
                % this is to preallocate tifstack for speed
                numFrames = length(1:numImCh:sizeStack);
                tifStack = zeros(width, height, numFrames); 
                
                % now load all tifs in stack into 3D matrix
                for i=1:numImCh:sizeStack
                    frame = imread(tifpath, 'tif', i); % open the TIF frame
                    frameNum = frameNum + 1;
                    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
                    %imwrite(frame*10, 'outfile.tif')
                end
                toc;
                
                %tifStack = tifStack(:,:, 1:length(frameTrig));  % trim frames for which there is no LabView signal
                
                tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)
                
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
                    frameAvg = mean(mean(tifStack,1),2);  % take average for each frame
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
                    
                else
                    C = [];
                end
                
                %% And tabulate indices of behavioral event types
                % (Extract values from behavioral event structure)
                % find the times of frames and do timecourse average based upon those times
                
                disp('Calculating event-triggered frame Ca avg');
                tic;
                
                % go ahead and unpack these because we're going to use it many times
%                 frameTrig = eventStruc.frameTrig;
                stimTrig = eventStruc.stimTrigTime;
                
                % put this in to limit frames to number of frame triggers
                % from galvo (in case I stopped labview before scanimage)
                % OR vice versa if there is an extra detected frame trigger
                
                if length(frameAvgDf) > length(frameTrig)
                    frameAvgDf = frameAvgDf(1:length(frameTrig));
                    if ~isempty(C)
                        C = C(1:length(frameTrig), :);
                    end
                elseif length(frameTrig) > length(frameAvgDf)
                    frameTrig = frameTrig(1:length(frameAvgDf));
                end
                
                fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names
                
                hz = dataFileArray{rowInd, 6};
                fps=hz;
                
                preFrame = 2*hz;    % number of frames to take before and after event time
                postFrame = 6*hz;
                
                % this loop unpacks all the structure fields into variables of the same name
                for field = 1:length(fieldNames)
                    
                    if ~isempty(eventStruc.(fieldNames{field}))
                        
                        % don't process stimTrig, frameTrig, and firstContactAbsT
                        if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
                            
                            eventName = genvarname(fieldNames{field});
                            
                            % if these are indices of trials, find corresponding times
                            if strfind(fieldNames{field}, 'StimInd')
                                eventTimes = stimTrig(eventStruc.(fieldNames{field}));
                            elseif strfind(fieldNames{field}, 'Time')
                                eventTimes = eventStruc.(fieldNames{field});
                                %             else eventTimes = 0;
                            end
                            
                            % only take event times that are within frame
                            % grab period (in case some things happen
                            % outside of this period, e.g. whisker hits)
                            eventTimes = eventTimes(eventTimes > (frameTrig(1)+2001) & eventTimes < (frameTrig(end)-6001));
                            
                            % eventEpochTool; % use subfunction to calculate event-trig Ca activ
                            
                            % for each event time, find the frame trigger index for the frame trig time closest to this  
                            for j=1:length(eventTimes)
                                zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
                            end
                            
                            % then find frame indices of a window around the event
                            beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
                            okInd = find(beginFrame > 0 & beginFrame < numFrames);  % make sure indices are all positive
                            beginFrame = beginFrame(okInd); % and only take these
                            zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
                            
                            endFrame = zeroFrame + postFrame;
                            okInd = find(endFrame > 0 & endFrame < numFrames); %
                            endFrame = endFrame(okInd);
                            zeroFrame = zeroFrame(okInd);   % just keep updated zeroFrames list for good measure
                            
                            eventCa = []; segEventCa = [];
                            
                            % find avg ca signal around each event
                            
                            for k = 1:length(endFrame)
                                try
                                % for frame avg Ca signal
                                eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
                                
                                % find event-triggered Ca of segmented
                                % ROIs, if present
                                if ~isempty(C)
                                    for roiNum = 1:size(C,2)
                                        roiDf = C(:,roiNum);
                                        segEventCa(:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
                                        
                                    end
                                else segEventCa = [];
                                end

                                %plot(corrRewCa(:,k));     
                                
                                catch
                                    disp(['Problem in processing event #' k ' of type ' eventName]);
                                end
                                
                            end
                            
                            % now construct the names of the event ca signals
                            eventNameCa = [eventName 'Ca'];
                            eventNameCaAvg = [eventName 'CaAvg'];
                            
                            % and average over all events of a type
                            eventCaAvg = mean(eventCa, 2);
                            
                            if ~isempty(C)
                                segEventCaAvg = mean(segEventCa, 3);
                                segStruc.(eventNameCa) = segEventCa;
                                segStruc.(eventNameCaAvg) = segEventCaAvg;
                                segStruc.hz = hz;
                            end
                            
                            
                            %eval([eventName ' = eventStruc.(fieldNames{field})']);
                            
                            % and put into structure for this day
                            dendriteBehavStruc.(eventNameCa) = eventCa;
                            dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
                            
                            
                            % concatenate average into batch struc for each
                            % framerate
                            if hz == 2
%                                 if num2hzFiles == 0
%                                     batchDendStruc2hz.(eventNameCaAvg) = [];
%                                 end
                                try
                                batchDendStruc2hz.(eventNameCaAvg) = [batchDendStruc2hz.(eventNameCaAvg) eventCaAvg];
                                catch
                                batchDendStruc2hz.(eventNameCaAvg) = eventCaAvg;
                                end
                                %num2hzFiles = num2hzFiles + 1;
                            elseif hz == 4
%                                 if num4hzFiles == 0
%                                     batchDendStruc4hz.(eventNameCaAvg) = [];
%                                 end
                                
                                try
                                    batchDendStruc4hz.(eventNameCaAvg) = [batchDendStruc4hz.(eventNameCaAvg) eventCaAvg];
                                catch
                                    batchDendStruc4hz.(eventNameCaAvg) = eventCaAvg;
                                end
                                %num4hzFiles = num4hzFiles + 1;
                            elseif hz == 8
%                                 if num8hzFiles == 0
%                                     batchDendStruc8hz.(eventNameCaAvg) = [];
%                                 end
                                
                                try
                                    batchDendStruc8hz.(eventNameCaAvg) = [batchDendStruc8hz.(eventNameCaAvg) eventCaAvg];
                                catch
                                    batchDendStruc8hz.(eventNameCaAvg) = eventCaAvg;
                                end
                                %num8hzFiles = num8hzFiles + 1;
                            end
                            
                            clear zeroFrame eventCa eventCaAvg;
                        end
                        
                    end
                end
                
                
                % get tif file name
                fn = filename(1:(strfind(filename, '.tif')-1));
                
                % and just save list of filenames in batch struc
                if hz == 2
                    num2hzFiles = num2hzFiles + 1;
                    batchDendStruc2hz.name{num2hzFiles} = fn;
                elseif hz == 4
                    num4hzFiles = num4hzFiles + 1;
                    batchDendStruc4hz.name{num4hzFiles} = fn;
                elseif hz == 8
                    num8hzFiles = num8hzFiles + 1;
                    batchDendStruc8hz.name{num8hzFiles} = fn;
                end
                
                
                % now just save the output structure for this session in this directory
                
                try
                save([fn '_seg_' date '.mat'], 'segStruc');
                catch
                    disp('no segStruc');
                end
                
                save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');
                
                clear tifStack;
                
                plotDendBehavAnal(dendriteBehavStruc, fn, fps);

                hgsave([fn '_' date '.fig']);
                
                toc;
                
%                 catch
%                     disp(['Error analyzing ' filename ', skipping file']);
%                 end
                
                
            end  % END IF this TIF folder is in dataFileArray
            end % END IF this is a directory (dayDir(b).isdir)
        end % END FOR loop looking through all files in this day's folder (for this animal)
        
    end   % END if isdir in home folder
    
end  % END searching through all days in animal folder

cd(parentFolder);

try
save(['batchDendStruc2hz_' date], 'batchDendStruc2hz');
catch
    disp('No 2hz files');
end

try
save(['batchDendStruc4hz_' date], 'batchDendStruc4hz');
catch
    disp('No 4hz files');
end

try
save(['batchDendStruc8hz_' date], 'batchDendStruc8hz');
catch
    disp('No 8hz files');
end

toc;