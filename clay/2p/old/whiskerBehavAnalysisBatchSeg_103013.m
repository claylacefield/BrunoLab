function  whiskerBehavAnalysisBatchSeg(dataFileArray, whiskSigType)

% [ whiskBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, hz, avg, roi)
% Master script for looking at behavior-triggered average calcium signals

% batchWhiskStruc2hz, batchWhiskStruc4hz

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the whiskBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse

% don't do segmented data for whisker analysis
seg=0;

cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

for mouse = 3:length(cageDir)
    
    if cageDir(mouse).isdir
        
        mouseName = cageDir(mouse).name;      % select the animal folder to analyze
        mouseFolder = [cageFolder '/' mouseName];
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
                        
                        % only process video
                        
                        if rowInd
                        
                        if strcmp(whiskSigType, 'video')
                        
                        if strcmp(dataFileArray{rowInd, 16}, 'beam')
                            
                          rowInd = 0;
                          
                        end
                        
                        end
                        
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
                            
                            % use special script for stage1b sessions
                            %                 if strfind(dataFileArray{rowInd, 8}, 'stage')
                            %
                            %                    [eventStruc] = detect2pEventsBatchStage1(dataFileArray, rowInd);
                            %
                            %                 else
                            
                            if strcmp(dataFileArray{rowInd, 16}, 'beam')
                                
                                [eventStruc, whiskSig1] = detect2pEventsBatchWhisk(dataFileArray, rowInd);  % detect2pEvents(nChannels, sf);
                                
                                whiskSig1 = whiskSig1/std(whiskSig1);
                                
                                frameTrig = 1:length(whiskSig1);
                                
                                sf = 1000; % sample frequency of whisker signal
                                
                            elseif strcmp(dataFileArray{rowInd, 16}, 'video')
                                [eventStruc, whiskSig1] = detect2pEventsBatchWhisk(dataFileArray, rowInd);
                                
                                timeMs = length(whiskSig1); % just use this whiskSig1 for total time in ms
                                
                                whiskSig1 = whiskVideoProcBatch(dataFileArray, rowInd); % now load in whisker sig from video (usu 30fps)
                                
                                sf = 30;
                                frameTrig = linspace(0, timeMs, length(whiskSig1)); % re-map times of whisker video frames
                            end
                            
                            % go ahead and unpack these because we're going to use it many times
                            %                 frameTrig = eventStruc.frameTrig;
                            stimTrig = eventStruc.stimTrigTime;
                            
                            %              end
                            
                            
                            whiskBehavStruc.eventStruc = eventStruc;
                            
                            %                 frameTrig = eventStruc.frameTrig; % unpack to trim frames if LabView stopped early
                            
                            toc;
                            
                            
                            %% Import the image stack
                            
                            %                 frameNum = 0;
                            %
                            %                 %filename = [dayDir(b).name '.tif'];
                            %                 tifpath = [dayPath dayDir(b).name '/' filename]; %[dayDir(b).name '.tif']];
                            %                 % NOTE: build the tifpath different because of the extra
                            %                 % folder layer for motion correction
                            %
                            %                 disp(['Processing image stack for ' filename]);
                            %                 tic;
                            %
                            %                 % see how big the image stack is
                            %                 stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
                            %                 sizeStack = length(stackInfo);  % no. frames in stack
                            %                 width = stackInfo(1).Width; % width of the first frame (and all others)
                            %                 height = stackInfo(1).Height;  % height of the first frame (and all others)
                            %
                            %                 clear stackInfo;    % clear this because it might be big
                            %
                            %                 % extract number of imaging channels and only take green for
                            %                 % ca++ activity
                            % %                 numImCh = dataFileArray{rowInd, 11};
                            %
                            %                 % NOTE: took prev. out because manually removed other chan
                            %                 numImCh = 1;
                            %
                            %                 % this is to preallocate tifstack for speed
                            %                 numFrames = length(1:numImCh:sizeStack);
                            %                 tifStack = zeros(width, height, numFrames);
                            %
                            %                 % now load all tifs in stack into 3D matrix
                            %                 for i=1:numImCh:sizeStack
                            %                     frame = imread(tifpath, 'tif', i); % open the TIF frame
                            %                     frameNum = frameNum + 1;
                            %                     tifStack(:,:,frameNum)= frame;  % make into a TIF stack
                            %                     %imwrite(frame*10, 'outfile.tif')
                            %                 end
                            %                 toc;
                            %
                            %                 %tifStack = tifStack(:,:, 1:length(frameTrig));  % trim frames for which there is no LabView signal
                            %
                            %                 tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)
                            %
                            %                 %numFrames = size(tifStack, 3);
                            
                            %% calculate ROI profiles
                            % select ImageJ ROI Manager MultiMeasure TXT file
                            % and extract timecourses of calcium activity
                            % NOTE: select all ROIs first, then whole frame avg
                            
                            avg = 0; roi = 0; % specify wheter to process frame mean profile and ROI profiles
                            
                            %                 if avg == 1 || roi == 1
                            %                     [roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);
                            %                 end
                            
                            %                 if avg == 0
                            %                     frameAvg = mean(mean(tifStack,1),2);  % take average for each frame
                            %                     frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
                            %                     % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
                            %
                            %                     % now doing this with the running mean (runmean from Matlab
                            %                     % Cntrl)
                            %
                            %                     runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
                            %
                            %                     frameAvgDf = (frameAvg - runAvg)./runAvg;
                            %
                            %                     % figure; plot(frameAvgDf);
                            %                 end
                            
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
                            
                            disp('calculating event-triggered whiskSig1 avg');
                            tic;
                            
                            
                            fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names
                            
                            hz = dataFileArray{rowInd, 6};
                            %hz = 1000;
                            
                            preFrame = 2*sf;    % number of frames to take before and after event time
                            postFrame = 6*sf;
                            
                            % this loop unpacks all the structure fields into variables of the same name
                            for field = 1:length(fieldNames)
                                
                                if ~isempty(eventStruc.(fieldNames{field}))
                                    
                                    % don't process stimTrig, frameTrig, and firstContactAbsT
                                    if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
                                        
                                        eventName = genvarname(fieldNames{field});
                                        
                                        % now construct the names of the event whiskSig signals
                                        eventNameWhiskSig = [eventName 'WhiskSig'];
                                        eventNameWhiskSigAvg = [eventName 'WhiskSigAvg'];
                                        
                                        % try/catch in case problem with some event
                                        % types
                                        try
                                            
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
                                            eventTimes = eventTimes(eventTimes > (2*sf+1) & eventTimes < (frameTrig(end)-(6*sf+1)));
                                            
                                            % eventEpochTool; % use subfunction to calculate event-trig whiskSig activ
                                            
                                            % for each event time, find the frame trigger index for the frame trig time closest to this
                                            for j=1:length(eventTimes)
%                                                 zeroFrame(j) = eventTimes(j);
                                                zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
                                                
                                            end
                                            
                                            numFrames = length(frameTrig);
                                            
                                            % then find frame indices of a window around the event
                                            beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
                                                                         okInd = find(beginFrame > 0 & beginFrame < numFrames);  % make sure indices are all positive
                                                                         beginFrame = beginFrame(okInd); % and only take these
                                                                        zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
                                            
                                            endFrame = zeroFrame + postFrame;
                                                                         okInd = find(endFrame > 0 & endFrame < numFrames); %
                                                                       endFrame = endFrame(okInd);
                                                                       zeroFrame = zeroFrame(okInd);   % just keep updated zeroFrames list for good measure
                                            
                                            eventWhiskSig = [];
                                            
                                            % find avg whiskSig signal around each event
                                            
                                            for k = 1:length(eventTimes)
                                                try
                                                    % for frame avg whiskSig signal
                                                    eventWhiskSig(:,k) = whiskSig1(beginFrame(k):endFrame(k));
                                                    
                                                    %plot(corrRewWhiskSig(:,k));
                                                    
                                                catch
                                                    disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
                                                end
                                                
                                            end
                                            
                                            %                             % now construct the names of the event whiskSig signals
                                            %                             eventNameWhiskSig = [eventName 'whiskSig'];
                                            %                             eventNameWhiskSigAvg = [eventName 'WhiskSigAvg'];
                                            
                                            % and average over all events of a type
                                            eventWhiskSigAvg = mean(eventWhiskSig, 2);
                                            
                                            %eval([eventName ' = eventStruc.(fieldNames{field})']);
                                            
                                            % and put into structure for this day
                                            whiskBehavStruc.(eventNameWhiskSig) = eventWhiskSig;
                                            whiskBehavStruc.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                            
                                            
                                            % concatenate average into batch struc for each
                                            % framerate
                                            if hz == 2
                                                %                                 if num2hzFiles == 0
                                                %                                     batchWhiskStruc2hz.(eventNameWhiskSigAvg) = [];
                                                %                                 end
                                                try
                                                    batchWhiskStruc2hz.(eventNameWhiskSigAvg) = [batchWhiskStruc2hz.(eventNameWhiskSigAvg) eventWhiskSigAvg];
                                                catch
                                                    batchWhiskStruc2hz.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                                end
                                                %num2hzFiles = num2hzFiles + 1;
                                            elseif hz == 4
                                                %                                 if num4hzFiles == 0
                                                %                                     batchWhiskStruc4hz.(eventNameWhiskSigAvg) = [];
                                                %                                 end
                                                
                                                try
                                                    batchWhiskStruc4hz.(eventNameWhiskSigAvg) = [batchWhiskStruc4hz.(eventNameWhiskSigAvg) eventWhiskSigAvg];
                                                catch
                                                    batchWhiskStruc4hz.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                                end
                                                %num4hzFiles = num4hzFiles + 1;
                                            elseif hz == 8
                                                %                                 if num8hzFiles == 0
                                                %                                     batchWhiskStruc8hz.(eventNameWhiskSigAvg) = [];
                                                %                                 end
                                                
                                                try
                                                    batchWhiskStruc8hz.(eventNameWhiskSigAvg) = [batchWhiskStruc8hz.(eventNameWhiskSigAvg) eventWhiskSigAvg];
                                                catch
                                                    batchWhiskStruc8hz.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                                end
                                                %num8hzFiles = num8hzFiles + 1;
                                            end
                                            
                                            clear zeroFrame eventWhiskSig eventWhiskSigAvg;
                                            
                                        catch
                                            disp(['problem processing: ' eventName]);
                                            whiskBehavStruc.(eventNameWhiskSig) = [];
                                            whiskBehavStruc.(eventNameWhiskSigAvg) = [];
                                        end
                                    end
                                    
                                end
                            end
                            
                            
                            % get tif file name
                            fn = filename(1:(strfind(filename, '.tif')-1));
                            
                            % and just save list of filenames in batch struc
                            if hz == 2
                                num2hzFiles = num2hzFiles + 1;
                                batchWhiskStruc2hz.name{num2hzFiles} = fn;
                            elseif hz == 4
                                num4hzFiles = num4hzFiles + 1;
                                batchWhiskStruc4hz.name{num4hzFiles} = fn;
                            elseif hz == 8
                                num8hzFiles = num8hzFiles + 1;
                                batchWhiskStruc8hz.name{num8hzFiles} = fn;
                            end
                            
                            
                            % now just save the output structure for this session in this directory
                            
                            %                 try
                            %                 save([fn '_seg_' date '.mat'], 'segStruc');
                            %                 catch
                            %                     disp('no segStruc');
                            %                 end
                            
                            save([fn '_whiskBehavStruc_' date], 'whiskBehavStruc');
                            
                            %clear tifStack;
                            
                            
                            %% plot output (and save graph)
                            %                 try
                            %                 plotDendBehavAnal(whiskBehavStruc, fn, fps);
                            %
                            %                 hgsave([fn '_' date '.fig']);
                            %                 catch
                            %                     disp('cannot plot output graphs');
                            %                 end
                            
                            toc;
                            
                            %                 catch
                            %                     disp(['Error analyzing ' filename ', skipping file']);
                            %                 end
                            
                            
                        end  % END IF this TIF folder is in dataFileArray
                    end % END IF this is a directory (dayDir(b).isdir)
                end % END FOR loop looking through all files in this day's folder (for this animal)
                
            end   % END if isdir in home folder
            
        end  % END searching through all days in animal folder
        
        cd(mouseFolder);
        
        try
            save(['batchWhiskStruc2hz_' date], 'batchWhiskStruc2hz');
        catch
            disp('No 2hz files');
        end
        
        try
            save(['batchWhiskStruc4hz_' date], 'batchWhiskStruc4hz');
        catch
            disp('No 4hz files');
        end
        
        try
            save(['batchWhiskStruc8hz_' date], 'batchWhiskStruc8hz');
        catch
            disp('No 8hz files');
        end
        
        toc;
        
    end % end IF cond. for cageDir(mouse).isdir
    
end  % end FOR loop of all mice in a cage