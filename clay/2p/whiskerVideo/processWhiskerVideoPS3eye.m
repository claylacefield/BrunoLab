function [whiskDataStruc] = processWhiskerVideoPS3eye(saveMem)

% Clay Sep.14,2015
% this is a wrapper script to run the functions that extract the frame
% times and average whisker angles

% saveMem variable just changes the way MP4 files are loaded using extractStimFrames, which is
% slower I think, but doesn't take as much RAM


sessionDir = dir;
sessionDirNames = {sessionDir.name};



%% load in measurements file
measInd = find(cellfun(@length, strfind(sessionDirNames, '.measurements')));
measFilename = sessionDir(measInd).name;

% load in dendriteBehavStruc (for aligning stim times to video of stim)
filename = measFilename(1:strfind(measFilename, '.measurements')-1);

% dbsInd = find(cellfun(@length, strfind(sessionDirNames, 'dendriteBehavStruc')));
% dbsDatenums = [sessionDir(dbsInd).datenum];
% [lsaMax, lastInd] = max(dbsDatenums);
% latestDbsInd = dbsInd(lastInd);
% load(sessionDir(latestDbsInd).name); 

dbsName = findLatestFilename('dendriteBehavStruc');
load(dbsName);

try 
    isempty(dendriteBehavStruc.eventStruc.correctRespStruc.stimTypeArr);
    
catch
    currPath = pwd;
    sl = strfind(currPath, '/');
    tifBasename = currPath(sl(end)+1:end);
    dayPath = currPath(1:sl(end));
    tifName = [tifBasename '.tif'];
    seg = 1; toProcess = 1;
    [dendriteBehavStruc] = dendriteBehavAnalysisNameSeg(tifName, dayPath, seg, toProcess);
end

try
    
    %testField = dendriteBehavStruc.eventStruc.correctRespStruc.stimTypeArr;

%% Calculate whisker video frame times    

mp4filename = [filename '.mp4'];
disp(['Computing whisker video frame times for ' mp4filename]); tic;
[frTimes, frameRate, frTopAv, errorCell] = extractStimFrames(mp4filename, dendriteBehavStruc, saveMem); toc;

%% Calculate whisker angles
disp(['Loading in ' measFilename]); tic;
measurements = LoadMeasurements(measFilename); toc;

% extract mean whisking
lengthThresh = 50; % this seems reasonable but haven't really explored
disp(['Computing mean whisker angles from ' measFilename]); tic;
[meanAngle, medianAngle, totalFr] = extractBestWhiskerAngles(measurements, lengthThresh); toc;
%clear(measurements);

% save everything to output structure
whiskDataStruc.meanAngle = meanAngle;
whiskDataStruc.medianAngle = medianAngle;
whiskDataStruc.totalFr = totalFr;
whiskDataStruc.frTimes = frTimes;
whiskDataStruc.frameRate = frameRate;
whiskDataStruc.frTopAv = frTopAv;

whiskDataStruc.errorCell = errorCell;

sessionPath = pwd;
whiskDataStruc.sessionPath = sessionPath;
whiskDataStruc.lengthThresh = lengthThresh;
whiskDataStruc.baseName = filename;

sessionName = sessionPath(end-13:end);
disp('Saving...');
save([sessionName '_whiskDataStruc_' date], 'whiskDataStruc');

catch
    disp(['Could not process whisker video so aborting ' filename]);
end

