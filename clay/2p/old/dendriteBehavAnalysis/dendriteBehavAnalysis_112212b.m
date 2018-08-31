

% Master script for looking at behavior-triggered average calcium signals


% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity

[roiStruc] = dendriteProfiles();


% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

[eventStruc] = detect2pEvents();

% NOTE: need to finish correct/incorrect and estimation of punishment times
% from behavioral event TXT file


% find the times of frames and do timecourse average based upon those times

