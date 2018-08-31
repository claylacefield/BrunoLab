function [dataFileArray] = moveCorrected(dataFileArray, mouseFolderList)

% This is a script to take all correctedUnplaced day folders of behavioral
% calcium imaging and put them into the correct animal folders. I used to
% do this manually but it was taking way too long.

% Steps:
% 1.) go to day folder, then TIF folders
% 2.) make sure there is a "corrected" folder (thus tif is probably behav
% stack)
% 3.) find the corresponding .txt and .bin (and .png) files to move, based
% upon datenum - tifDatenum
% 4.) use the names of these to find mouse name and then mouse folder
% 5.) move TIF folder and corresponding behav files to mouse folder


correctedPath = '/home/clay/Documents/Data/motionCorrected/toMove';

cd(correctedPath);

corrDir = dir;  % dir of correctedUnplaced folder

% look through all dayFolders in correctedUnplaced
for dayNum = 3:length(corrDir)
    
    if ~isempty(strfind(corrDir(dayNum).name, '20')) && corrDir(dayNum).isdir  % if day folder year is in this millennium
        
        dayFolderName = corrDir(dayNum).name;
        
        cd([correctedPath '/' dayFolderName]);   % go to day folder
        
        dayFolderDir = dir;
        
        for daySessionNum = 3:length(dayFolderDir)
            
            if dayFolderDir(daySessionNum).isdir % should only get tif folders
                
                tifFolderName = dayFolderDir(daySessionNum).name;
                
                % also check here to make sure not already moved
                % i.e. not already in dataFileArray
                if isempty(find(strcmp([tifFolderName '.tif'], dataFileArray(:,1)))) && dayFolderDir(daySessionNum).isdir
                    
                    cd(tifFolderName);
                    
                    tifFolderDir = dir;
                    
                    % only move if "corrected" present
                    if find(cellfun(@length, strfind({tifFolderDir.name}, 'corrected')))
                        
                        tifInd = find(cellfun(@length, strfind({tifFolderDir.name}, '.tif')));
                        
                        tifFileName = tifFolderDir(tifInd).name;
                        
                        tifDatenum = tifFolderDir(tifInd).datenum;
                        
                        disp(['Processing: ' tifFolderName]);
                        tic;
                        
                        cd ..;
                        
                        try
                            % find corresponding TXT file (and use this for the basis
                            % for .bin and to find mouse name
                            txtInd = find(cellfun(@length, strfind({dayFolderDir.name}, '.txt')));  % get dir indices of .txt files
                            txtDatenum = [dayFolderDir(txtInd).datenum]; % get datenums of .txt files
                            [minDiff, minDiffInd] = min(abs(txtDatenum - tifDatenum)); % find the .txt file acquired closest to the .tif file
                            txtFileName = dayFolderDir(txtInd(minDiffInd)).name;
                            basenameTxt = txtFileName(1:(strfind(txtFileName, '.txt')-1));
                            
                            mouseName = basenameTxt(13:(length(basenameTxt)-1));
                            
                            mouseRowInd = find(strcmp(mouseName, mouseFolderList(:,1)));
                            
                            mouseFolderCell = mouseFolderList(mouseRowInd, 2);
                            
                            mouseFolderPath = mouseFolderCell{1};
                            
                            dayPath = [correctedPath '/' dayFolderName];
                            
                            destPath = [mouseFolderPath '/' dayFolderName]; % create dest pathname
                            
                            % now create .bin/.png names
                            binFileName = [basenameTxt '.bin'];
                            pngFileName = [basenameTxt '.png'];
                            
                            % create target day folder for this session if necessary
                            if ~exist(destPath)
                                mkdir(destPath);
                            end
                            
                            if ~exist([destPath '/' tifFolderName])
                                
                                % create source filepaths
                                tifFolderSource = [dayPath '/' tifFolderName];
                                txtSource = [dayPath '/' txtFileName];
                                binSource = [dayPath '/' binFileName];
                                pngSource = [dayPath '/' pngFileName];
                                
                                % and copy files to appropriate folder
                                
                                copyfile(tifFolderSource, [destPath '/' tifFolderName] );
                                copyfile(txtSource, destPath);
                                copyfile(binSource, destPath);
                                copyfile(pngSource, destPath);
                                
                            end     % end IF cond for whether tifFolder already exists
                            
                            % and write into dataFileArray filenames of moved files
                            if isempty(find(strcmp([tifFolderName '.tif'], dataFileArray(:,1))))
                                dataFileLength = size(dataFileArray, 1);
                                dataFileArray(dataFileLength+1, 1) = {tifFileName};
                                dataFileArray(dataFileLength+1, 2) = {mouseName};
                                dataFileArray(dataFileLength+1, 3) = {binFileName};
                                dataFileArray(dataFileLength+1, 4) = {txtFileName};
                            end
                            
                        catch
                            disp('WARNING: cannot find .txt file so moving on');
                        end
                                            
                    toc;
                        
                    end     % end IF for corrected present

                    
                end     % end IF for file not already in dataFileArray
                
            end     % end IF cond for daySessionFolder isdir
            
            cd([correctedPath '/' dayFolderName]); 
            
        end  % end FOR loop of all sessions in dayFolder
        
    end % end if day folder is this millennium and isdir
    
    cd(correctedPath);  % go back to correctedUnplaced folder
    
end     % end FOR loop looking through all folders in correctedUnplaced folder
