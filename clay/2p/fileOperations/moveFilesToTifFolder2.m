function moveFilesToTifFolder2()

% NOTE: this version is for mouse/toCorrect folder of days

% This script takes all the files from a day directory of 2p imaging and
% puts all the relevant associated files (.bin, .txt, etc.) into the
% appropriate TIF directory

% fileEndingCell = {'.bin' '.txt' '.png' '.mp4' '.mkv' '.whiskers' '.meaurements' };

% select home folder to analyze
homeFolder = uigetdir;

cd(homeFolder);
%[pathname homeName] = fileparts(homeFolder);
homeDir = dir;

for a = 3:length(homeDir) % for each day of imaging in this animal's dir
    
    if homeDir(a).isdir %&& totalSessNum <= 3
        
        try
            
            dayName = homeDir(a).name;
            
            dayPath = [homeFolder '/' dayName];
            
            cd(dayPath); % go to this day of imaging
            
            dayDir = dir;
            dayDatenums = [dayDir.datenum];
            dayFilenames = {dayDir.name};
            
            numBinfiles = 0; numTiffiles = 0;
            tifDatenumArr = []; tifBasenameCell = {}; tifNameCell = {};
            binNameCell = {}; binDatenumArr = [];
            
            for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
                if dayDir(b).isdir
                    
                    
                    tifBasename = dayDir(b).name;
                    
                    tifFolderPath = [dayPath '/' tifBasename];
                    
                    cd(tifFolderPath);
                    
                    tifName = [tifBasename '.tif'];
                    
                    
                    tifPath = [tifFolderPath '/' tifName];
                    
                    %filename = filename(1:(strfind(filename, '.tif')+3));
                    
                    tifFile = dir(tifPath);
                    
                    if tifFile.bytes > 1e7  % weeds out frameAvg/structural
                        numTiffiles = numTiffiles + 1;
                        tifDatenum = tifFile.datenum;
                        
                        tifDatenumArr(numTiffiles) = tifDatenum;
                        tifNameCell{numTiffiles} = tifName;
                        tifBasenameCell{numTiffiles} = tifBasename;
                        
                    end
                    
                    cd(dayPath);
                    
                    %dayDir = dir;
                    %dayDatenums = [dayDir.datenum];
                    
                elseif ~isempty(strfind(dayDir(b).name, '.bin'))
                    numBinfiles = numBinfiles + 1;
                    binNameCell{numBinfiles} = dayDir(b).name;
                    binDatenumArr(numBinfiles) = dayDir(b).datenum;
                    
                end  % end IF checking if this is a folder therefore session folder
            end  % end FOR looking through all files/folders in dayDir
            
            
            % at this point we should have arrays/cells of all bin files and
            % tif files
            
            % for each bin file
            for numBin = 1:numBinfiles
                binName = binNameCell{numBin};
                binBasename = binName(1:(strfind(binName, '.bin')-1));
                binDatenum = binDatenumArr(numBin);
                
                % find the closest tif file datenum
                [tifVal, tifInd] = min(abs(tifDatenumArr-binDatenum));
                tifBasename = tifBasenameCell{tifInd};
                
                % build destination path (tifFolder)
                tifFolderPath = [dayPath '/' tifBasename];
                
                % move .bin/txt/png/mkv files to correct tifFolder
                
                sameSessInds = find(cellfun(@length, strfind(dayFilenames, binBasename)));
                
                for fileNum = 1:length(sameSessInds)
                    filePath = [dayPath '/' dayDir(sameSessInds(fileNum)).name];
                    movefile(filePath, tifFolderPath);
                end
                
            end
            
        catch
            disp(['Problem processing day ' homeDir(a).name]);
        end
        
    end  % end IF dayFolder isDir
end  % end FOR looking through all day folders in homeDir


