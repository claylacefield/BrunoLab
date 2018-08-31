function [batchDendriteBehavStruc] = dendriteBehavAnalysisBatch(dataFileArray)

% [ dendriteBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, hz, avg, roi)
% Master script for looking at behavior-triggered average calcium signals


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


%   % to find indices of a particular animal
%   arrLog = strcmp('W10', dataFileArray);  % gives logical array
%   rowInd = find(arrLog(:,2));     % find row indices where animal found
%   % OR
%   rowInd = find(strcmp('W10', {dataFileArray{:,2}}));
%   % which is the same as
%   rowInd = find(strcmp('W10', dataFileArray(:,2)));


for a = 3:length(parentDir) % for each day of imaging in this animal's dir
    
    dayPath = [parentFolder '/' parentDir(a).name '/'];
    
    cd(dayPath); % go to this day of imaging
    
    dayDir = dir;
    
    for b = 3:length(dayDir);   % for each file in this day
        
        % see if this file is on the dataFileArray TIF list (and if so, what
        % row?)
        rowInd = find(strcmp(dayDir(b).name, dataFileArray(:,1)));
        
        % if it is in list, then process data
        
        if rowInd
            %% Import the image stack
            
            frameNum = 0;
            
            filename = dayDir(b).name;
            tifpath = [dayPath filename];
            
            % see how big the image stack is
            stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
            sizeStack = length(stackInfo);  % no. frames in stack
            width = stackInfo(1).Width; % width of the first frame (and all others)
            height = stackInfo(1).Height;  % height of the first frame (and all others)
            
            clear stackInfo;    % clear this because it might be big
            
            for i=1:sizeStack
                frame = imread(tifpath, 'tif', i); % open the TIF frame
                frameNum = frameNum + 1;
                tifStack(:,:,frameNum)= frame;  % make into a TIF stack
                %imwrite(frame*10, 'outfile.tif')
            end
            
            tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)
            
            numFrames = sizeStack;
            
            %% Calculate ROI profiles
            % select ImageJ ROI Manager MultiMeasure TXT file
            % and extract timecourses of calcium activity
            % NOTE: select all ROIs first, then whole frame avg
            
            avg = 0; roi = 0; % specify wheter to process frame mean profile and ROI profiles
            
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
            
            
            %% Detect behavioral event times from BIN file and event type indices from TXT
            % select behavior signal BIN file and behavior event TXT file
            % and extract times of particular events
            
            [eventStruc] = detect2pEventsBatch(dataFileArray, rowInd, 1000);  % detect2pEvents(nChannels, sf);
            
            
            % And tabulate indices of behavioral event types
            % (Extract values from behavioral event structure)
            % find the times of frames and do timecourse average based upon those times
            
            % go ahead and unpack these because we're going to use it many times
            frameTrig = eventStruc.frameTrig;
            stimTrig = eventStruc.stimTrig;
            
            fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names
            
            hz = dataFileArray{rowInd, 6};
            
            preFrame = 2*hz;    % number of frames to take before and after event time
            postFrame = 6*hz;
            
            % this loop unpacks all the structure fields into variables of the same name
            for field = 1:length(fieldNames)
                
                if ~isempty(eventStruc.(fieldNames{field}))
                    
                    % don't process stimTrig, frameTrig, and firstContactAbsT
                    if isempty(strfind(fieldNames{field}, 'Trig')) && isempty(strfind(fieldNames{field}, 'AbsT')) && isempty(strfind(fieldNames{field}, 'licks'))
                        
                        eventName = genvarname(fieldNames{field});
                        
                        % if these are indices of trials, find corresponding times
                        if strfind(fieldNames{field}, 'Ind')
                            eventTimes = stimTrig(eventStruc.(fieldNames{field}));
                        else
                            eventTimes = eventStruc.(fieldNames{field});
                        end
                        
                        eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end));
                        
                        % eventEpochTool; % use subfunction to calculate event-trig Ca activ
                        
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
                        
                        % find avg ca signal around each event
                        for k = 1:length(endFrame)
                            
                            eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
                            
                            %             if roi == 1
                            %                 for roiNum = 1:length(roiStruc)
                            %                     roiDf = roiStruc(roiNum).roiDf;
                            %                     ROIcorrFirstContactCa (:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
                            %
                            %                 end
                            %             end
                            
                            %plot(corrRewCa(:,k));
                            
                        end
                        
                        % and average over all events of a type
                        eventCaAvg = mean(eventCa, 2);
                        
                        %eval([eventName ' = eventStruc.(fieldNames{field})']);
                        
                        % now construct the names of the event ca signals
                        eventNameCa = [eventName 'Ca'];
                        eventNameCaAvg = [eventName 'CaAvg'];
                        
                        % and put into structure for this day
                        dendriteBehavStruc.(eventNameCa) = eventCa;
                        dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
                        
                        clear zeroFrame eventCa eventCaAvg;
                    end
                    
                end
            end
            
            
            % now just save the output structure in this directory
            fn = filename(1:(strfind(filename, '.tif')-1));
            
            save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');
            
            clear tifStack;
            
        end
    end
    
end
