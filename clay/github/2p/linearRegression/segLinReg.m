function  [segLinRegStruc] = segLinReg(dataFileArray, frameShift)

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
                                
                                
                                %% load in good segments
                                
                                C = segStruc.C;  % load in matrix of segment timecourses (dim: #frames, #seg )
                                
                                C = C(:,goodSeg);   % and only take segments listed in goodSeg
                                
                                %% load in the continuous signals for linear
                                % regression
                                
                                cd(dayPath);
                                
                                x2 = binRead2pBatch(dataFileArray, rowInd);
                                
                                if dataFileArray{rowInd,14}==4
                                    whiskSig1 = x2(4,:);
                                    whiskSig2 = x2(5,:);
                                else
                                    whiskSig1 = x2(5,:);
                                    whiskSig2 = x2(4,:);
                                end
                                
                                % randy's script assumes BOT = 5, so make it so
                                
                                x2(5,:) = whiskSig1;
                                x2(4,:) = whiskSig2;
                                
                                clear whiskSig1 whiskSig2;
                                
                                
                                %% go through all segments and do linear regression on each
                                segLinRegStruc.mouse(numMouse).session(numSessions).name = basename;
                                
                                for numSeg = 1:length(goodSeg)
                                    
                                    frameAvgDf = C(:,numSeg);
                                    
                                    %% perform linear regression using randy's
                                    % script
                                    
                                    mdl = RegressClayCalciumShift2(x2, frameAvgDf, frameShift);
                                    
                                    clear frameAvgDf;
                                    
                                    % get tif file name
                                    %fn = filename(1:(strfind(filename, '.tif')-1));
                                    
                                    % save stuff to output struc (need to increment
                                    % numSessions)
                                    
                                    disp(['saving to struc mouse# ' num2str(numMouse) ' Session ' num2str(numSessions) ' SegNum= ' num2str(goodSeg(numSeg))]);
                                    
                                    segLinRegStruc.mouse(numMouse).session(numSessions).seg(numSeg).segNum = goodSeg(numSeg);
                                    segLinRegStruc.mouse(numMouse).session(numSessions).seg(numSeg).coeffNames = mdl.CoefficientNames;
                                    segLinRegStruc.mouse(numMouse).session(numSessions).seg(numSeg).coeff = mdl.Coefficients;
                                    segLinRegStruc.mouse(numMouse).session(numSessions).seg(numSeg).Rsqr = mdl.Rsquared;
                                end
                                
                                clear goodSeg x2 mdl;
                                
                            end % end IF EXIST goodSeg.mat
                            
                        end  % END IF this TIF folder is in dataFileArray (" if rowInd")
                    end % END IF this is a directory (dayDir(b).isdir)
                end % END FOR loop looking through all files in this day's folder (for this animal)
                
            end   % END if isdir in home folder
            
        end  % END searching through all days in animal folder
        
        cd(mouseFolder);
        
        %clear batchDendStruc2hz batchDendStruc4hz batchDendStruc8hz;
        
    end     % end IF cond for mouseDir = folder
end     % end FOR loop for all mouse folders in cageDir

cd ..

save(['segLinRegStruc_shift' num2str(frameShift) '-' date '.mat'], 'segLinRegStruc');