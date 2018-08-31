function  [unitEpochCompilStruc] = unitEpochCompilMouse(fileTag)

% USAGE: [unitEpochArr] = unitEpochCompilMouse(dataFileArray);

toPlot = 0;

mouseFolder = uigetdir;      % select the animal folder to analyze

cd(mouseFolder);
%[pathname animalName] = fileparts(mouseFolder);
mouseDir = dir;

tic;

%   % to find indices of a particular animal
%   arrLog = strcmp('W10', dataFileArray);  % gives logical array
%   rowInd = find(arrLog(:,2));     % find row indices where animal found
%   % OR
%   rowInd = find(strcmp('W10', {dataFileArray{:,2}}));
%   % which is the same as
%   rowInd = find(strcmp('W10', dataFileArray(:,2)));

unitRewEpochArr = [];
unitRewEpochArr2 = [];
unitUnrewEpochArr = [];
unitUnrewEpochArr2 = [];

session = 0;

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
                    
                    try
                    
                    cd(dayPath);
                    
                    disp(['Processing: ' filename]);
                    tic;

                    if isempty(strfind(dataFileArray{rowInd, 8}, 'stage'))
                        
                        session = session + 1; 
                        
                        basename = filename(1:(strfind(filename, '.tif')-1));
                        cd([dayPath basename]); % go to tifFolder
                        
                        tifDir = dir;
                        
                        tifDatenums = [tifDir.datenum];
                        tifFilenames = {tifDir.name};
                        
                        % find latest segStruc for this session and load
                        segFileInd = find(not(cellfun('isempty', strfind(tifFilenames, 'seg'))));
                        segFileDatenums = tifDatenums(segFileInd);
                        [segSortDatenums, segSortInd] = sort(segFileDatenums);
                        % [maxSegDatenum, maxSegInd] = max(segFileDatenums);
                        %load(tifDir(segFileInd(maxSegInd)).name);
                        load(tifDir(segFileInd(segSortInd(end-1))).name);
                        
                        % and load in goodSeg2
                        goodSegFileInd = find(not(cellfun('isempty', strfind(tifFilenames, 'goodSeg2'))));
                        
                        if ~isempty(goodSegFileInd)
                            load(tifDir(goodSegFileInd).name);
                        else
                            goodSegFileInd = find(not(cellfun('isempty', strfind(tifFilenames, 'goodSeg.mat'))));
                            load(tifDir(goodSegFileInd).name);
                        end
                        
                        % now find the unit epoch rates for this session
                        [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg);
                        
                        rewEpRate = unitEpochStruc.rewEpRate;
                        rewEpRate2 = unitEpochStruc.rewEpRate2;
                        unrewEpRate = unitEpochStruc.unrewEpRate;
                        unrewEpRate2 = unitEpochStruc.unrewEpRate2;
                        
                        unitRewEpochArr = [unitRewEpochArr; rewEpRate];
                        unitRewEpochArr2 = [unitRewEpochArr2; rewEpRate2];
                        unitUnrewEpochArr = [unitUnrewEpochArr; unrewEpRate];
                        unitUnrewEpochArr2 = [unitUnrewEpochArr2; unrewEpRate2];

                    end
                    
                    catch
                        disp(['Could not process: ' filename]);
                    end
                    
                    toc;
                    
                    % now just save the output structure for this session in this directory
                    
%                     try
%                         save([fn '_seg_' date '.mat'], 'segStruc');
%                         clear segStruc;
%                     catch
%                         disp('no segStruc');
%                     end
%                     
%                     save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');
%                     
%                     clear tifStack dendriteBehavStruc roiPkArr;


                end  % END IF this TIF folder is in dataFileArray
            end % END IF this is a directory (dayDir(b).isdir)
        end % END FOR loop looking through all files in this day's folder (for this animal)
        
    end   % END if isdir in home folder
    
end  % END searching through all days in animal folder

unitEpochCompilStruc.unitRewEpochArr = unitRewEpochArr;
unitEpochCompilStruc.unitRewEpochArr2 = unitRewEpochArr2;
unitEpochCompilStruc.unitUnrewEpochArr = unitUnrewEpochArr;
unitEpochCompilStruc.unitUnrewEpochArr2 = unitUnrewEpochArr2;

cd(mouseFolder);

% try
%     save(['batchDendStruc2hz_' date], 'batchDendStruc2hz');
%     clear batchDendStruc2hz;
% catch
%     disp('No 2hz files');
% end
% 
% try
%     save(['batchDendStruc4hz_' date], 'batchDendStruc4hz');
%     clear batchDendStruc4hz;
% catch
%     disp('No 4hz files');
% end
% 
% try
%     save(['batchDendStruc8hz_' date], 'batchDendStruc8hz');
%     clear batchDendStruc8hz;
% catch
%     disp('No 8hz files');
% end

%clear batchDendStruc2hz batchDendStruc4hz batchDendStruc8hz;

toc;

