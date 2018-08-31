function  [badStartSigCell] = findBadStartSigsMouse(dataFileArray)

% USAGE: dendriteBehavAnalysis(dataFileArray, seg, saveTif)
% Master script for looking at behavior-triggered average calcium signals

% output: batchDendStruc2hz, batchDendStruc4hz
% and dendriteBehavStruc in each session folder

% "Batch" for all files for a cage present in dataFileArray
% "Seg2" for also analyzing event-triggered timecourses of 
%       segmented data (with new segmentation, seg2)

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the dendriteBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse

toPlot = 0;

numBadStartSig = 0;

badStartSigCell = {};

% cageFolder = uigetdir;      % select the cage folder to analyze
% cd(cageFolder);
% %[pathname animalName] = fileparts(mouseFolder);
% cageDir = dir;

mouseFolder = uigetdir;

% for mouse = 3:length(cageDir)
%     
%     if cageDir(mouse).isdir
%         
%         mouseName = cageDir(mouse).name;      % select the animal folder to analyze
%         mouseFolder = [cageFolder '/' mouseName];
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
                        
                        disp(['Processing ' filename]);
                        
                        filename = filename(1:(strfind(filename, '.tif')+3));
                        
                        rowInd = find(strcmp(filename, dataFileArray(:,1)));
                        
                        if isempty(rowInd)
                            filename2 = [filename ''''];
                            rowInd = find(strcmp(filename2, dataFileArray(:,1)));
                        end
                        
                        % if it is in list, then process data
                        
                        if rowInd
                            
                            [x2] = binRead2pBatch(dataFileArray, rowInd);
                            
                            
                            disp(['Checking ' filename ' for bad start sig']);
                            if max(x2(1,:)) < 4
                            numBadStartSig = numBadStartSig +1;
                            badStartSigCell{numBadStartSig} = filename;
                            end
                            
                        end  % END IF this TIF folder is in dataFileArray
                    end % END IF this is a directory (dayDir(b).isdir)
                end % END FOR loop looking through all files in this day's folder (for this animal)
                
            end   % END if isdir in home folder
            
        end  % END searching through all days in animal folder
        
        
        cd(mouseFolder);
        
        toc;
        
    end
% end