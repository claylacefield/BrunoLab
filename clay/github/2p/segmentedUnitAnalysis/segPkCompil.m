function  [segPkStruc] = segPkCompil(dataFileArray)

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

load('masterFieldNames.mat');

numMouse = 0;

for mouse = 3:length(cageDir)
    
    if cageDir(mouse).isdir
        
        numMouse = numMouse + 1;
        
        disp(['numMouse = ' num2str(numMouse)]);
        
        mouseName = cageDir(mouse).name;      % select the animal folder to analyze
        mouseFolder = [cageFolder '/' mouseName];
        cd(mouseFolder);
        %[pathname animalName] = fileparts(mouseFolder);
        mouseDir = dir;
        
        numSessions = 0;
        
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
                            
                            basename = filename(1:(strfind(filename, '.tif')-1));
                            cd([dayPath basename]);
                            
                            if exist('goodSeg.mat', 'file')
                                
                                %                 cd(dayDir(b).name);  % NO, stay in the day folder
                                %                 % tif directory
                                
                                disp(['Processing ' filename]);
                                
                                numSessions = numSessions + 1;
                                
                                tifDir = dir;
                                
                                for d = 3:length(tifDir)
                                    if ~isempty(strfind(tifDir(d).name, 'seg_06-Jan-2014'))
                                        disp(['loading in latest segmented file: ' tifDir(d).name]);
                                        load(tifDir(d).name);
                                        load('goodSeg.mat');
                                    end
                                end
                                
                                
                                %% so at this point, we're in the tif directory, and segStruc is loaded
                                
                                
                                %% now find peaks for each field, for each dendrite
                                
                                fieldNames = fieldnames(segStruc);
                                
                                % and find what indices these fields are in
                                % masterFieldNames list
                                
                                [masterFieldLog, masterFieldInd] = ismember(fieldNames, masterFieldNames);
                                
                                numField = 0;
                                
                                % this loop unpacks all the structure fields into variables of the same name
                                for field = 1:length(fieldNames)
                                    
                                    %                                 disp('Looking through all fields');
                                    
                                    if ~isempty(segStruc.(fieldNames{field}))
                                        
                                        % don't process stimTrig, frameTrig, and firstContactAbsT
                                        if ~isempty(strfind(fieldNames{field}, 'Ca')) && isempty(strfind(fieldNames{field}, 'CaAvg'))
                                            
                                            numField = numField + 1;
                                            fieldInd(numField) = field;
                                            
                                            eventName = genvarname(fieldNames{field});
                                            
                                            % now construct the names of the event ca signals
                                            eventNameCa = [eventName 'Ca'];
                                            eventNameCaAvg = [eventName 'CaAvg'];
                                            
                                            %                                         disp(['Finding peaks in ' fieldNames{field}]);
                                            
                                            try
                                                % for frame avg Ca signal
                                                % load in this event field (all
                                                % segments)
                                                eventCa = segStruc.(fieldNames{field}); % dim = 33x50
                                                
                                                % find event-triggered Ca of segmented
                                                % ROIs, if present
                                                %                                                 if ~isempty(C)
                                                for roiNum = 1:length(goodSeg)  % for all good segments
                                                    segEventCa = squeeze(eventCa(:,goodSeg(roiNum),:));    % dim = 33x50segx#event
                                                    
                                                    %% now find peak
                                                    % amplitude and
                                                    % time
                                                    
                                                    segEventCaAvg = mean(segEventCa, 2);
                                                    segEventCaSEM = std(segEventCa,0,2)/sqrt(size(segEventCa,2));
                                                    
                                                    % now find peaks in Ca data for each field
                                                    
                                                    [caPkVal, caPkInd] = max(segEventCaAvg(8:16)); % find peak
                                                    caAvgPkVal(numField, roiNum) = caPkVal-mean(segEventCaAvg(1:5))-segEventCaSEM(caPkInd+7);
                                                    caAvgPkInd(numField, roiNum) = caPkInd+7;
                                                    
                                                end
                                                %                                                 else segEventCa = [];
                                                %                                                 end
                                                
                                                %plot(corrRewCa(:,k));
                                                
                                            catch
                                                disp(['Problem in processing event of type ' eventName]);
                                            end
                                            
                                        end  % end IF for 'CaAvg' event fields
                                        
                                    end     % end IF for event field not empty
                                    
                                    %[maxPkFieldVal, maxPkFieldInd] = max(caAvgPkVal);
                                    
                                    %maxFieldName= fieldNames{maxPkFieldInd};
                                    
                                end     % end FOR loop for all fields in segStruc
                                
                                %%
                                % So at this point, we have matrices of pkVal
                                % and pkInd for each field in segStruc, for each goodSeg
                                
                                % get tif file name
                                fn = filename(1:(strfind(filename, '.tif')-1));
                                
                                % save stuff to output struc (need to increment
                                % numSessions)
                                
                                disp(['saving to struc mouse# ' num2str(numMouse) ' Session ' num2str(numSessions)]);
                                
                                segPkStruc.mouse(numMouse).session(numSessions).name = fn;
                                %                             segPkStruc.mouse(mouse).session(numSessions).fieldNames = fieldNames; % NOTE: this is ALL fieldNames (i.e. even ones not processed)
                                segPkStruc.mouse(numMouse).session(numSessions).goodSeg = goodSeg;
                                segPkStruc.mouse(numMouse).session(numSessions).caAvgPkVal = caAvgPkVal;
                                segPkStruc.mouse(numMouse).session(numSessions).caAvgPkInd = caAvgPkInd;
                                %                             segPkStruc.mouse(mouse).session(numSessions).fieldInd = fieldInd;   % use this with fieldNames to find which fields processed into caPkVal
                                segPkStruc.mouse(numMouse).session(numSessions).fieldNames = fieldNames(fieldInd);
                                
                                %                 catch
                                %                     disp(['Error analyzing ' filename ', skipping file']);
                                %                 end
                                
                                clear caAvgPkVal caAvgPkInd fieldInd fieldNames goodSeg;
                                
                            end % end IF EXIST goodSeg.mat
                            
                        end  % END IF this TIF folder is in dataFileArray
                    end % END IF this is a directory (dayDir(b).isdir)
                end % END FOR loop looking through all files in this day's folder (for this animal)
                
            end   % END if isdir in home folder
            
        end  % END searching through all days in animal folder
        
        cd(mouseFolder);
        
        %clear batchDendStruc2hz batchDendStruc4hz batchDendStruc8hz;
        
    end     % end IF cond for mouseDir = folder
end     % end FOR loop for all mouse folders in cageDir

cd(cageFolder);
save(['segPkStruc_' date '.mat'], 'segPkStruc');