function moveFilesToTifFolder()


% This script takes all the files from a day directory of 2p imaging and
% puts all the relevant associated files (.bin, .txt, etc.) into the
% appropriate TIF directory

% fileEndingCell = {'.bin' '.txt' '.png' '.mp4' '.mkv' '.whiskers' '.meaurements' };

% select home folder to analyze
homeFolder = uigetdir;

cd(homeFolder);
[pathname homeName] = fileparts(homeFolder);
homeDir = dir;

for a = 3:length(homeDir) % for each day of imaging in this animal's dir
    
    if homeDir(a).isdir %&& totalSessNum <= 3
        
        dayName = homeDir(a).name;
        
        dayPath = [homeFolder '/' dayName];
        
        cd(dayPath); % go to this day of imaging
        
        dayDir = dir;
        dayDatenums = [dayDir.datenum];
        dayFilenames = {dayDir.name};
        
        for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
            if dayDir(b).isdir
                
                tifBasename = dayDir(b).name;
                
                tifFolderPath = [dayPath '/' tifBasename];
                
                tifName = [tifBasename '.tif'];
                
                tifPath = [tifFolderPath '/' tifName];
                
                %filename = filename(1:(strfind(filename, '.tif')+3));
                
                tifFile = dir(tifPath);
                tifDatenum = tifFile.datenum;
                
                cd(dayPath);
                
                %dayDir = dir;
                %dayDatenums = [dayDir.datenum];
                
                try
                    
                    binInd = find(cellfun(@length, strfind(dayFilenames, '.bin')));  % get dir indices of .txt files
                    binDatenum = [dayDir(binInd).datenum]; % get datenums of .txt files
                    [minDiff, minDiffInd] = min(abs(binDatenum - tifDatenum)); % find the .txt file acquired closest to the .tif file
                    
                    % only move if bin file is within a certain period of
                    % time
                    if minDiff < 0.001
                        binName = dayDir(binInd(minDiffInd)).name;
                        sessBasename = binName(1:strfind(binName, '.bin')-1);
                        
                        % now based upon the session basename, move all of the
                        % files with this name to the correct TIF folder
                        
                        sameSessInds = find(cellfun(@length, strfind(dayFilenames, sessBasename)));
                        
                        for fileNum = 1:length(sameSessInds)
                            filePath = [dayPath '/' dayDir(sameSessInds(fileNum)).name];
                            movefile(filePath, tifFolderPath);
                        end
                        
                    else
                        disp('Couldnt find .bin file for this TIF');
                        
                    end
                    
                catch
                    disp(['Problem with ' tifName]);
                end
                
            end
        end
    end
end