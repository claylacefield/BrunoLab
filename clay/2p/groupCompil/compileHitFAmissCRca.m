function  [batchDendStruc2hz, batchDendStruc4hz, batchDendStruc8hz] = compileHitFAmissCRca(dataFileArray)

%% USAGE: [batchDendStruc2hz, batchDendStruc4hz, batchDendStruc8hz] = compileHitFAmissCRca(dataFileArray);
% 122314 clay
% goes through cage folder and makes 


nans2(1:17) = NaN;
nans4(1:33) = NaN;
nans8(1:65) = NaN;

% nans2ev(1:8001) = NaN;
% nans4ev(1:8001) = NaN;
% nans8ev(1:8001) = NaN;


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
        
        fieldCell = {'hitFAisoLevCaAvg' 'missCRisoLevCaAvg' 'hitFAisoLickCaAvg' 'missCRisoLickCaAvg'};
        
        
        % initialize output struc (in order to concat subsequent sessions)
        for field = 1:length(fieldCell)
            try
                batchDendStruc2hz.(fieldCell{field}) = [];
                batchDendStruc4hz.(fieldCell{field}) = [];
                batchDendStruc8hz.(fieldCell{field}) = [];
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
                                    dendStrucNum = 0;
                                    
                                    for numFile = 1:length(currDir)

                                        if ~isempty(strfind(currDir(numFile).name, 'dendriteBehavStruc')) %&& firstFile2 == 0
                                            dendStrucNum = dendStrucNum + 1;
                                            dendBehavStrucNum(dendStrucNum) = numFile;
                                        end
                                        
                                    end
                                    
                                    % 072414 now find most recent cognate eventHist files and load in

                                    [newestDendDatenum, newestDendInd] = max([currDir(dendBehavStrucNum).datenum]);
                                    
                                    inStruc = load(currDir(dendBehavStrucNum(newestDendInd)).name);
                                    fieldNamesEvSt = fieldnames(inStruc);
                                    dendriteBehavStruc = inStruc.(fieldNamesEvSt{1});
                                    
                                    clear dendBehavStrucNum newestDendInd fieldNamesEvSt inStruc;
                                    
                                    
                                    %% find hitFAmissCR calcium for this dataset
                                    try
                                    [hitFAisoLevCa, missCRisoLevCa] = hitFAmissCRca(dendriteBehavStruc, 'isoLevLiftTime');
                                    [hitFAisoLickCa, missCRisoLickCa] = hitFAmissCRca(dendriteBehavStruc, 'isoLickTime');
                                    catch
                                        disp('Cannot calculate hitFAmissCR data');
                                    end
                                    
                                    try
                                    dendriteBehavStruc.hitFAisoLevCaAvg = mean(hitFAisoLevCa, 2); % then take average for this session
                                    dendriteBehavStruc.hitFAisoLickCaAvg = mean(hitFAisoLickCa, 2); 
                                    catch
                                        disp('Cannot calculate hitFAisoLevCaAvg');
                                    end
                                    
                                    try
                                    dendriteBehavStruc.missCRisoLevCaAvg = mean(missCRisoLevCa, 2);
                                    dendriteBehavStruc.missCRisoLickCaAvg = mean(missCRisoLickCa, 2);
                                    catch
                                        disp('Cannot calculate missCRisoLevCaAvg');
                                    end
                                    
                                    %% Fieldnames loop
                                    % this loop unpacks all the structure fields into variables of the same name
                                    
                                    %fieldNames = masterFieldNamesCaAvg;
                                    %fieldNames2 = masterFieldNamesEventHist;
                                    fieldNames = fieldCell;
                                    
                                    for field = 1:length(fieldNames)
                                        
                                        try
                                            sessionFieldData = dendriteBehavStruc.(fieldNames{field});
                                            %sessionEventData = eventHistBehavStruc.(fieldNames2{field});
                                            
                                            processField = 1;
                                        catch
                                            if hz == 2
                                                batchDendStruc2hz.(fieldNames{field}) = [batchDendStruc2hz.(fieldNames{field}) nans2'];
                                                %batchEventHistStruc2hz.(fieldNames2{field}) = [batchEventHistStruc2hz.(fieldNames2{field}) nans2ev'];
                                                %num2hzFiles = num2hzFiles + 1;
                                            elseif hz == 4
                                                batchDendStruc4hz.(fieldNames{field}) = [batchDendStruc4hz.(fieldNames{field}) nans4'];
                                                %batchEventHistStruc4hz.(fieldNames2{field}) = [batchEventHistStruc4hz.(fieldNames2{field}) nans4ev'];
                                                %num4hzFiles = num4hzFiles + 1;
                                            elseif hz == 8
                                                batchDendStruc8hz.(fieldNames{field}) = [batchDendStruc8hz.(fieldNames{field}) nans8'];
                                                %batchEventHistStruc8hz.(fieldNames2{field}) = [batchEventHistStruc8hz.(fieldNames2{field}) nans8ev'];
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
                                                %batchEventHistStruc2hz.(fieldNames2{field}) = [batchEventHistStruc2hz.(fieldNames2{field}) sessionEventData];
                                                %num2hzFiles = num2hzFiles + 1;
                                            elseif hz == 4
                                                batchDendStruc4hz.(fieldNames{field}) = [batchDendStruc4hz.(fieldNames{field}) sessionFieldData];
                                                %batchEventHistStruc4hz.(fieldNames2{field}) = [batchEventHistStruc4hz.(fieldNames2{field}) sessionEventData];
                                                %num4hzFiles = num4hzFiles + 1;
                                            elseif hz == 8
                                                batchDendStruc8hz.(fieldNames{field}) = [batchDendStruc8hz.(fieldNames{field}) sessionFieldData];
                                                %batchEventHistStruc8hz.(fieldNames2{field}) = [batchEventHistStruc8hz.(fieldNames2{field}) sessionEventData];
                                                %num8hzFiles = num8hzFiles + 1;
                                            end
                                            
                                            clear sessionFieldData sessionEventData; 
                                            
                                            % end
                                            
                                        end     % end IF for processing this field
                                    end     % end FOR loop for all fieldnames
                                    
                                    clear dendriteBehavStruc;
                                    
                                    fn = filename(1:(strfind(filename, '.tif')-1));
                                    
                                    % and just save list of filenames in batch struc
                                    if hz == 2
                                        num2hzFiles = num2hzFiles + 1;
                                        batchDendStruc2hz.name{num2hzFiles} = fn;
                                        %batchEventHistStruc2hz.name{num2hzFiles} = fn;
                                    elseif hz == 4
                                        num4hzFiles = num4hzFiles + 1;
                                        batchDendStruc4hz.name{num4hzFiles} = fn;
                                        %batchEventHistStruc4hz.name{num4hzFiles} = fn;
                                    elseif hz == 8
                                        num8hzFiles = num8hzFiles + 1;
                                        batchDendStruc8hz.name{num8hzFiles} = fn;
                                        %batchEventHistStruc8hz.name{num8hzFiles} = fn;
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
        
        
        
        %clear batchDendStruc2hz batchDendStruc4hz batchDendStruc8hz;
        
        
        toc;
        
    end
end