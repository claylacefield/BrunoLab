function  dendriteBehavAnalysisMouse(seg, toProcess) % , filterDate)

% USAGE: dendriteBehavAnalysisMouse(seg, toProcess)
% Master script for looking at behavior-triggered average calcium signals

% output: dendriteBehavStruc in each session folder


% Arguments:
% seg = 1 to processes segmented data
% toProcess = 0 to process new data (no dbs, segStruc), 1 to process all
% data (new and old), 2 to reprocess stage1 data

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

toc;
