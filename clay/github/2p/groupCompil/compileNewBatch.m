function  compileNewBatch(dataFileArray, masterFieldNamesCaAvg, masterFieldNamesEventHist)

%% USAGE: compileNewBatch(dataFileArray, masterFieldNamesCaAvg, masterFieldNamesEventHist);
% Master script for looking at behavior-triggered average calcium signals
% FROM cageBatchAvg
% 072414


% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the dendriteBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse



nans2(1:17) = NaN;
nans4(1:33) = NaN;
nans8(1:65) = NaN;

nans2ev(1:8001) = NaN;
nans4ev(1:8001) = NaN;
nans8ev(1:8001) = NaN;


cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

% for each mouse in cageDir
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
        
        for field = 1:length(masterFieldNamesCaAvg)
            try
                batchDendStruc2hz.(masterFieldNamesCaAvg{field}) = [];
                batchDendStruc4hz.(masterFieldNamesCaAvg{field}) = [];
                batchDendStruc8hz.(masterFieldNamesCaAvg{field}) = [];
                batchEventHistStruc2hz.(masterFieldNamesEventHist{field}) = [];
                batchEventHistStruc4hz.(masterFieldNamesEventHist{field}) = [];
                batchEventHistStruc8hz.(masterFieldNamesEventHist{field}) = [];
            catch
                %dbs.(masterFieldNamesCa{field}) = [];
            end
            
        end
        
        tic;
        
        % go through all days of imaging for this animal
        for a = 3:length(mouseDir) % for each day of imaging in this animal's dir
            
            % for each day
            if mouseDir(a).isdir
                
                dayPath = [mouseFolder '/' mouseDir(a).name '/'];
                
                cd(dayPath); % go to this day of imaging
                
                dayDir = dir;
                
                % go through every session for that day
                for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
                    if dayDir(b).isdir
                        %% NEED TO ADD NEW LEVEL FOR TIF IN FOLDER FOR MOTION CORRECTION
                        
                        % see if this file is on the dataFileArray TIF list (and if so, what
                        % row?)
                        filename = [dayDir(b).name '.tif'];
                        
                        filename = filename(1:(strfind(filename, '.tif')+3));
                        
                        % see if this session is in dataFileArray to
                        % analyze (and which row if so)
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
                            
                            hz = dataFileArray{rowInd, 6};
                            fps=hz;
                            
                            tic;
                            
                            cd(filename(1:strfind(filename, '.tif')-1));
                            
                            %                             try  % with CATCH around 467
                            
                            % use special script for stage1b sessions
                            if isempty(strfind(dataFileArray{rowInd, 8}, 'stage'))
                                try
                                    
                                    %% load in the latest analyzed data for this session
                                    currDir = dir;
                                    evFileNum = 0;
                                    dendStrucNum = 0;
                                    evFileNum = 0;
                                    
                                    for numFile = 1:length(currDir)
                                        
                                        % look for eventHist (may be caps or not) and make list of indices in currDir
                                        if ~isempty(strfind(currDir(numFile).name, 'ventHist'))
                                            evFileNum = evFileNum + 1;
                                            eventStrucNum(evFileNum) = numFile;
                                        end
                                        
                                        if ~isempty(strfind(currDir(numFile).name, 'dendriteBehavStruc')) %&& firstFile2 == 0
                                            dendStrucNum = dendStrucNum + 1;
                                            dendBehavStrucNum(dendStrucNum) = numFile;
                                        end
                                        
                                    end
                                    
                                    % 072414 now find most recent cognate eventHist files and load in
                                    [newestEvDatenum, newestEvInd] = max([currDir(eventStrucNum).datenum]);
                                    
                                    inStruc = load(currDir(eventStrucNum(newestEvInd)).name);
                                    fieldNamesEvSt = fieldnames(inStruc);
                                    eventHistBehavStruc = inStruc.(fieldNamesEvSt{1});
                                    
                                    clear eventStrucNum newestEvInd fieldNamesEvSt inStruc;
                                    
                                    
                                    [newestDendDatenum, newestDendInd] = max([currDir(dendBehavStrucNum).datenum]);
                                    
                                    inStruc = load(currDir(dendBehavStrucNum(newestDendInd)).name);
                                    fieldNamesEvSt = fieldnames(inStruc);
                                    dendriteBehavStruc = inStruc.(fieldNamesEvSt{1});
                                    
                                    clear dendBehavStrucNum newestDendInd fieldNamesEvSt inStruc;
                                    
                                    
                                    %% Fieldnames loop
                                    % this loop unpacks all the structure fields into variables of the same name
                                    
                                    fieldNames = masterFieldNamesCaAvg;
                                    fieldNames2 = masterFieldNamesEventHist;
                                    
                                    for field = 1:length(fieldNames)
                                        
                                        try
                                            sessionFieldData = dendriteBehavStruc.(fieldNames{field});
                                            sessionEventData = eventHistBehavStruc.(fieldNames2{field});
                                            processField = 1;
                                        catch
                                            if hz == 2
                                                batchDendStruc2hz.(fieldNames{field}) = [batchDendStruc2hz.(fieldNames{field}) nans2'];
                                                batchEventHistStruc2hz.(fieldNames2{field}) = [batchEventHistStruc2hz.(fieldNames2{field}) nans2ev'];
                                                %num2hzFiles = num2hzFiles + 1;
                                            elseif hz == 4
                                                batchDendStruc4hz.(fieldNames{field}) = [batchDendStruc4hz.(fieldNames{field}) nans4'];
                                                batchEventHistStruc4hz.(fieldNames2{field}) = [batchEventHistStruc4hz.(fieldNames2{field}) nans4ev'];
                                                %num4hzFiles = num4hzFiles + 1;
                                            elseif hz == 8
                                                batchDendStruc8hz.(fieldNames{field}) = [batchDendStruc8hz.(fieldNames{field}) nans8'];
                                                batchEventHistStruc8hz.(fieldNames2{field}) = [batchEventHistStruc8hz.(fieldNames2{field}) nans8ev'];
                                                %num8hzFiles = num8hzFiles + 1;
                                            end % end IF for concat into struc at diff fps
                                            processField = 0;
                                        end
                                        
                                        if  processField == 1 %&& ~isempty(dendriteBehavStruc.(fieldNames{field}))
                                            
                                            %sessionFieldData = dendriteBehavStruc.(fieldNames{field});
                                            
                                            % concatenate average into batch struc for each
                                            % framerate
                                            if hz == 2
                                                batchDendStruc2hz.(fieldNames{field}) = [batchDendStruc2hz.(fieldNames{field}) sessionFieldData];
                                                batchEventHistStruc2hz.(fieldNames2{field}) = [batchEventHistStruc2hz.(fieldNames2{field}) sessionEventData];
                                                %num2hzFiles = num2hzFiles + 1;
                                            elseif hz == 4
                                                batchDendStruc4hz.(fieldNames{field}) = [batchDendStruc4hz.(fieldNames{field}) sessionFieldData];
                                                batchEventHistStruc4hz.(fieldNames2{field}) = [batchEventHistStruc4hz.(fieldNames2{field}) sessionEventData];
                                                %num4hzFiles = num4hzFiles + 1;
                                            elseif hz == 8
                                                batchDendStruc8hz.(fieldNames{field}) = [batchDendStruc8hz.(fieldNames{field}) sessionFieldData];
                                                batchEventHistStruc8hz.(fieldNames2{field}) = [batchEventHistStruc8hz.(fieldNames2{field}) sessionEventData];
                                                %num8hzFiles = num8hzFiles + 1;
                                            end
                                            
                                            clear sessionFieldData sessionEventData; 
                                            
                                            % end
                                            
                                        end     % end IF for processing this field
                                    end     % end FOR loop for all fieldnames
                                    
                                    clear dendriteBehavStruc eventHistBehavStruc;
                                    
                                    fn = filename(1:(strfind(filename, '.tif')-1));
                                    
                                    % and just save list of filenames in batch struc
                                    if hz == 2
                                        num2hzFiles = num2hzFiles + 1;
                                        batchDendStruc2hz.name{num2hzFiles} = fn;
                                        batchEventHistStruc2hz.name{num2hzFiles} = fn;
                                    elseif hz == 4
                                        num4hzFiles = num4hzFiles + 1;
                                        batchDendStruc4hz.name{num4hzFiles} = fn;
                                        batchEventHistStruc4hz.name{num4hzFiles} = fn;
                                    elseif hz == 8
                                        num8hzFiles = num8hzFiles + 1;
                                        batchDendStruc8hz.name{num8hzFiles} = fn;
                                        batchEventHistStruc8hz.name{num8hzFiles} = fn;
                                    end
                                    
                                catch
                                    disp(['Problem processing file: ' filename]);
                                end
                                
                            end % end IF for not stage1b file
                            
                            toc;
                            
                        end  % END IF this TIF folder is in dataFileArray
                    end % END IF this is a directory (dayDir(b).isdir)
                    
                    cd(dayPath);
                    
                end % END FOR loop looking through all files in this day's folder (for this animal)
                
            end   % END if isdir in home folder
            
        end  % END searching through all days in animal folder
        
        cd(mouseFolder);
        
        if num2hzFiles > 0
        %try
            save(['batchDendStruc2hz_' date], 'batchDendStruc2hz');
            save(['batchEventHistStruc2hz_' date], 'batchEventHistStruc2hz');
            clear batchDendStruc2hz batchEventHistStruc2hz;
        %catch
        else
            disp('No 2hz files');
        %end
        end
        
        if num4hzFiles > 0
        %try
            save(['batchDendStruc4hz_' date], 'batchDendStruc4hz');
            save(['batchEventHistStruc4hz_' date], 'batchEventHistStruc4hz');
            clear batchDendStruc4hz batchEventHistStruc4hz;
        %catch
        else
            disp('No 4hz files');
        %end
        end
        
        if num8hzFiles > 0
        %try
            save(['batchDendStruc8hz_' date], 'batchDendStruc8hz');
            save(['batchEventHistStruc8hz_' date], 'batchEventHistStruc8hz');
            clear batchDendStruc8hz batchEventHistStruc8hz;
        %catch
        else
            disp('No 8hz files');
        %end
        end
        
        %clear batchDendStruc2hz batchDendStruc4hz batchDendStruc8hz;
        
        
        toc;
        
    end
end