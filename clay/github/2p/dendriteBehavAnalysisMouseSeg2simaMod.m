function  dendriteBehavAnalysisMouseSeg2simaMod(seg, toProcess) % , filterDate)

% USAGE: dendriteBehavAnalysis(dataFileArray, seg, saveTif)
% Master script for looking at behavior-triggered average calcium signals

% output: batchDendStruc2fps, batchDendStruc4fps
% and dendriteBehavStruc in each session folder

% "Cage" for all files for a cage present in dataFileArray
% "Seg2" for also analyzing event-triggered timecourses of
%       segmented data (with new segmentation, seg2)
% "sima" because motion correction folder structure was from
%       later correction with SIMA
% "New" because as of 051815, not using dataFileArray and just taking
% relevant files that I have started putting all into the TIF folder
% "Mod" because as of 012816, it's modular, calling a subfunction for each
% session (makes it easier to generalize for diff folder structures)

% Arguments:
% seg = 1 to processes segmented data
% toProcess = 0 to process new data (no dbs, segStruc), 1 to process all
% data (new and old), 2 to reprocess stage1 data

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the dendriteBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse

% NOTE: that really the only reason to use the dataFileArray is
% for getting the imaging rate, and also to see if the behav program
% is stage1b.
%
% Change Notes:
% 050415: putting in errorCell to compile possible errors, and adding in
% filterDate argument to select out particular segmentation dates for
% analysis

toPlot = 0;

mouseFolder = uigetdir;      % select the cage folder to analyze


% mouseName = cageDir(mouse).name;      % select the animal folder to analyze
cd(mouseFolder);
%[pathname animalName] = fileparts(mouseFolder);
mouseDir = dir;


% num2hzFiles = 0;
% num4hzFiles = 0;
% num8hzFiles = 0;

tic;


for a = 3:length(mouseDir) % for each day of imaging in this animal's dir
    
    if mouseDir(a).isdir
        
        dayPath = [mouseFolder '/' mouseDir(a).name '/'];
        
        cd(dayPath); % go to this day of imaging
        
        dayDir = dir;
        
        for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
            if dayDir(b).isdir
                
                tifBasename = dayDir(b).name;
                filename = [tifBasename '.tif'];
                
                try
                dendriteBehavAnalysisNameSeg(filename, dayPath, seg, toProcess);
                catch
                    disp(['Problem processing ' filename]);
                end
                
            end % END IF this is a directory (dayDir(b).isdir)
        end % END FOR loop looking through all files in this day's folder (for this animal)
        cd(dayPath);
    end   % END if isdir in home folder
    cd(mouseFolder);
end  % END searching through all days in animal folder

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

%clear batchDendStruc2fps batchDendStruc4fps batchDendStruc8fps;

toc;
