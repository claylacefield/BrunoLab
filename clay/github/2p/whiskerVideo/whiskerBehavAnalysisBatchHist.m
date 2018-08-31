function  whiskerBehavAnalysisBatchHist(dataFileArray, whiskSigType)

% [ whiskHistBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, hz, avg, roi)
% Master script for looking at behavior-triggered average calcium signals

% batchWhiskHistStruc2hz, batchWhiskHistStruc4hz

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the whiskHistBehavStruc_(TIF filename) in the same
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
                            
                            whiskSig1 = [];
                            
                            if strcmp(dataFileArray{rowInd, 16}, 'beam')
                                
                                [eventStruc, whiskSig1] = detect2pEventsBatchWhisk(dataFileArray, rowInd);  % detect2pEvents(nChannels, sf);
                                
                                whiskSig1 = whiskSig1 - runmean(whiskSig1, 20);
                                
                                whiskSig1 = whiskSig1/max(whiskSig1);
                                
                                frameTrig = 0:(length(whiskSig1)-1);
                                
                                sf = 1000; % sample frequency of whisker signal
                                
                            elseif strcmp(dataFileArray{rowInd, 16}, 'video')
                                [eventStruc, whiskSig1] = detect2pEventsVidBatch(dataFileArray, rowInd);
                                
                                totalMs = eventStruc.totalMs; % 
                                
                                whiskSig1 = whiskVideoProcBatch(dataFileArray, rowInd); % now load in whisker sig from video (usu 30fps)
                                
                                sf = 30;
                                frameTrig = linspace(0, totalMs, length(whiskSig1)); % re-map times of whisker video frames
                            end
                            
                            % using Randy's function to make thresholded
                            % whisker signal for histogram (120413)
                            
                            whiskContacts1 = threshold(whiskSig1, 0.07, 8);
                            whiskContacts2 = zeros(length(whiskContacts1),1);
                            whiskContacts2(whiskContacts1) = 1;
                            
                            
                            % go ahead and unpack these because we're going to use it many times
                            %                 frameTrig = eventStruc.frameTrig;
                            stimTrig = eventStruc.stimTrigTime;
                            
                            %              end
                            
                            
                            whiskHistBehavStruc.eventStruc = eventStruc;
                            
                            %                 frameTrig = eventStruc.frameTrig; % unpack to trim frames if LabView stopped early
                            
                            toc;
                            
                            
                            %% Import the image stack
                            
                          
                            %% calculate ROI profiles
                            % select ImageJ ROI Manager MultiMeasure TXT file
                            % and extract timecourses of calcium activity
                            % NOTE: select all ROIs first, then whole frame avg
                            
                            avg = 0; roi = 0; % specify wheter to process frame mean profile and ROI profiles
                            
                         
                            
                           
                            
                            %% And tabulate indices of behavioral event types
                            % (Extract values from behavioral event structure)
                            % find the times of frames and do timecourse average based upon those times
                            
                            disp('calculating event-triggered whiskSig1 avg');
                            tic;
                            
                            
                            fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names
                            
                            hz = dataFileArray{rowInd, 6};  % hz=fps;
                            %hz = 1000;
                            
                            preFrame = 2*sf;    % number of frames to take before and after event time
                            postFrame = 6*sf;   % note that for whisker, sf is beam or video rate (1000 or 30)
                            
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
                                            eventTimes = eventTimes(eventTimes > (frameTrig(1)+2001) & eventTimes < (frameTrig(end)-6001));
                                            
                                            % eventEpochTool; % use subfunction to calculate event-trig whiskSig activ
                                            
                                            % for each event time, find the frame trigger index for the frame trig time closest to this
                                            for j=1:length(eventTimes)
%                                                 zeroFrame(j) = eventTimes(j);
                                                zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
                                                
                                            end
                                            
                                            numFrames = length(frameTrig);
                                            
                                            % then find frame indices of a window around the event
                                            beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
                                            okInd = find(beginFrame >= 0 & beginFrame <= (numFrames-8*sf));  % make sure indices are all positive
                                            beginFrame = beginFrame(okInd); % and only take these
                                            zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
                                            
                                            endFrame = zeroFrame + postFrame;
                                            okInd2 = find(endFrame >= 8*sf & endFrame <= numFrames); %
                                            endFrame = endFrame(okInd2);
                                            zeroFrame = zeroFrame(okInd2);   % just keep updated zeroFrames list for good measure
                                            beginFrame = beginFrame(okInd2);
                                            
                                            eventWhiskSig = [];
                                            
                                            % find avg whiskSig signal around each event
                                            
                                            for k = 1:length(eventTimes)
                                                try
                                                    % for frame avg whiskSig signal
                                                    eventWhiskSig(:,k) = whiskContacts2(beginFrame(k):endFrame(k));
                                                    
                                                    %plot(corrRewWhiskSig(:,k));
                                                    
                                                catch
                                                    disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
                                                end
                                                
                                            end
                                            
                                            %                             % now construct the names of the event whiskSig signals
                                            %                             eventNameWhiskSig = [eventName 'whiskSig'];
                                            %                             eventNameWhiskSigAvg = [eventName 'WhiskSigAvg'];
                                            
                                            % and average over all events of a type
                                            %eventWhiskSigAvg = mean(eventWhiskSig, 2);
                                            
                                            % or for histogram 120513
                                            
                                            eventWhiskSigAvg = sum(eventWhiskSig,2)/size(eventWhiskSig,2);
                                            
                                            %eval([eventName ' = eventStruc.(fieldNames{field})']);
                                            
                                            % and put into structure for this day
                                            whiskHistBehavStruc.(eventNameWhiskSig) = eventWhiskSig;
                                            whiskHistBehavStruc.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                            
                                            
                                            % concatenate average into batch struc for each
                                            % framerate
                                            if hz == 2
                                                %                                 if num2hzFiles == 0
                                                %                                     batchWhiskHistStruc2hz.(eventNameWhiskSigAvg) = [];
                                                %                                 end
                                                try
                                                    batchWhiskHistStruc2hz.(eventNameWhiskSigAvg) = [batchWhiskHistStruc2hz.(eventNameWhiskSigAvg) eventWhiskSigAvg];
                                                catch
                                                    batchWhiskHistStruc2hz.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                                end
                                                %num2hzFiles = num2hzFiles + 1;
                                            elseif hz == 4
                                                %                                 if num4hzFiles == 0
                                                %                                     batchWhiskHistStruc4hz.(eventNameWhiskSigAvg) = [];
                                                %                                 end
                                                
                                                try
                                                    batchWhiskHistStruc4hz.(eventNameWhiskSigAvg) = [batchWhiskHistStruc4hz.(eventNameWhiskSigAvg) eventWhiskSigAvg];
                                                catch
                                                    batchWhiskHistStruc4hz.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                                end
                                                %num4hzFiles = num4hzFiles + 1;
                                            elseif hz == 8
                                                %                                 if num8hzFiles == 0
                                                %                                     batchWhiskHistStruc8hz.(eventNameWhiskSigAvg) = [];
                                                %                                 end
                                                
                                                try
                                                    batchWhiskHistStruc8hz.(eventNameWhiskSigAvg) = [batchWhiskHistStruc8hz.(eventNameWhiskSigAvg) eventWhiskSigAvg];
                                                catch
                                                    batchWhiskHistStruc8hz.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                                                end
                                                %num8hzFiles = num8hzFiles + 1;
                                            end
                                            
                                            clear zeroFrame eventWhiskSig eventWhiskSigAvg;
                                            
                                        catch
                                            disp(['problem processing: ' eventName]);
                                            whiskHistBehavStruc.(eventNameWhiskSig) = [];
                                            whiskHistBehavStruc.(eventNameWhiskSigAvg) = [];
                                        end
                                    end
                                    
                                end
                            end
                            
                            
                            % get tif file name
                            fn = filename(1:(strfind(filename, '.tif')-1));
                            
                            % and just save list of filenames in batch struc
                            if hz == 2
                                num2hzFiles = num2hzFiles + 1;
                                batchWhiskHistStruc2hz.name{num2hzFiles} = fn;
                            elseif hz == 4
                                num4hzFiles = num4hzFiles + 1;
                                batchWhiskHistStruc4hz.name{num4hzFiles} = fn;
                            elseif hz == 8
                                num8hzFiles = num8hzFiles + 1;
                                batchWhiskHistStruc8hz.name{num8hzFiles} = fn;
                            end
                            
                            
                            % now just save the output structure for this session in this directory
                            
                            %                 try
                            %                 save([fn '_seg_' date '.mat'], 'segStruc');
                            %                 catch
                            %                     disp('no segStruc');
                            %                 end
                            
                            save([fn '_whiskHistBehavStruc_' date], 'whiskHistBehavStruc');
                            
                            %clear tifStack;
                            
                            
                            %% plot output (and save graph)
                            %                 try
                            %                 plotDendBehavAnal(whiskHistBehavStruc, fn, fps);
                            %
                            %                 hgsave([fn '_' date '.fig']);
                            %                 catch
                            %                     disp('cannot plot output graphs');
                            %                 end
                            
                            toc;
                            
                            %                 catch
                            %                     disp(['Error analyzing ' filename ', skipping file']);
                            %                 end
                            
                            clear whiskHistBehavStruc;
                            
                        end  % END IF this TIF folder is in dataFileArray
                    end % END IF this is a directory (dayDir(b).isdir)
                end % END FOR loop looking through all files in this day's folder (for this animal)
                
            end   % END if isdir in home folder
            
        end  % END searching through all days in animal folder
        
        cd(mouseFolder);
        
        try
            save(['batchWhiskHistStruc2hz_' date], 'batchWhiskHistStruc2hz');
            clear batchWhiskHistStruc2hz;
        catch
            disp('No 2hz files');
        end
        
        try
            save(['batchWhiskHistStruc4hz_' date], 'batchWhiskHistStruc4hz');
            clear batchWhiskHistStruc4hz;
        catch
            disp('No 4hz files');
        end
        
        try
            save(['batchWhiskHistStruc8hz_' date], 'batchWhiskHistStruc8hz');
            clear batchWhiskHistStruc8hz;
        catch
            disp('No 8hz files');
        end
        
        toc;
        
    end % end IF cond. for cageDir(mouse).isdir
    
end  % end FOR loop of all mice in a cage