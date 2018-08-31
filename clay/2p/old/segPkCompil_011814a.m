function  segPkCompil(dataFileArray, seg, toPlot)

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
                        
                        % if it is in list, then process data
                        
                        if rowInd
                            
                            %                 cd(dayDir(b).name);  % NO, stay in the day folder
                            %                 % tif directory
                            
                            disp(['Processing ' filename]);
                            
                           
                            %toc;
                            
                                basename = filename(1:(strfind(filename, '.tif')-1));
                                cd([dayPath basename]);
                                
                                tifDir = dir;
                                
                                for d = 3:length(tifDir)
                                    if (~isempty(strfind(tifDir(d).name, 'seg_06-Jan-2014')) && prevSeg == 0)
                                        disp(['loading in first segmented file: ' tifDir(d).name]);
                                        load(tifDir(d).name);
                                        C = segStruc.C;
                                        load('goodSeg.mat');
                                    end
                                end
                                
                            
                            %% so at this point, we're in the tif directory, and segStruc is loaded
                            
                            
                            %% now find peaks for each field, for each dendrite

                            
                            % this loop unpacks all the structure fields into variables of the same name
                            for field = 1:length(fieldNames)
                                
                                if ~isempty(eventStruc.(fieldNames{field}))
                                    
                                    % don't process stimTrig, frameTrig, and firstContactAbsT
                                    if ~isempty(strfind(fieldNames{field}, 'CaAvg'))
                                        
                                        eventName = genvarname(fieldNames{field});
                                        
                                        % now construct the names of the event ca signals
                                        eventNameCa = [eventName 'Ca'];
                                        eventNameCaAvg = [eventName 'CaAvg'];
                                        
                                        try
                                            
                                            
                                                try
                                                    % for frame avg Ca signal
                                                    % load in this event field (all
                                                    % segments)
                                                     eventCa = segStruc.(fieldNames{field});
                                                    
                                                    % find event-triggered Ca of segmented
                                                    % ROIs, if present
                                                    if ~isempty(C)
                                                        for roiNum = 1:length(goodSeg)  % for all good segments
                                                            segEventCa = eventCa(:,goodSeg(roiNum));
                                                            
                                                            % now find peak
                                                            % amplitude and
                                                            % time
                                                           
                                                            
                                                            
                                                        end
                                                    else segEventCa = [];
                                                    end
                                                    
                                                    %plot(corrRewCa(:,k));
                                                    
                                                catch
                                                    disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
                                                end

                                            
                                            %                             % now construct the names of the event ca signals
                                            %                             eventNameCa = [eventName 'Ca'];
                                            %                             eventNameCaAvg = [eventName 'CaAvg'];
                                            
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
                                            
                                        catch
                                            disp(['problem processing: ' eventName]);
                                            dendriteBehavStruc.(eventNameCa) = [];
                                            dendriteBehavStruc.(eventNameCaAvg) = [];
                                        end
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
                                clear segStruc;
                            catch
                                disp('no segStruc');
                            end
                            
                            save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');
                            
                            clear tifStack dendriteBehavStruc;
                            
                            
                            %% plot output (and save graph)
                            
                            if toPlot
                                try
                                    plotDendBehavAnal(dendriteBehavStruc, fn, fps);
                                    
                                    hgsave([fn '_' date '.fig']);
                                catch
                                    disp('cannot plot output graphs');
                                end
                            end
                            
                            toc;
                            
                            %                 catch
                            %                     disp(['Error analyzing ' filename ', skipping file']);
                            %                 end
                            
                            clear dendriteBehavStruc;
                            
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
        
        %clear batchDendStruc2hz batchDendStruc4hz batchDendStruc8hz;
        
        toc;
        
    end
end