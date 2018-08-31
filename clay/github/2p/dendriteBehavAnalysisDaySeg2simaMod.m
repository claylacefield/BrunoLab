function  dendriteBehavAnalysisDaySeg2simaMod(seg, toProcess, saveTif) % , filterDate)

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

dayPath = uigetdir;      % select the cage folder to analyze


cd(dayPath); % go to this day of imaging

dayDir = dir;

for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
    if dayDir(b).isdir
        
        tifBasename = dayDir(b).name;
        filename = [tifBasename '.tif'];
        
        dendriteBehavAnalysisNameSeg(filename, dayPath, seg, toProcess, saveTif);
        
    end % END IF this is a directory (dayDir(b).isdir)
    cd(dayPath);
end % END FOR loop looking through all files in this day's folder (for this animal)



