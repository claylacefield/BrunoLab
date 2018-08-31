function compileSummaryDataAll(mouseFolderList)




% This is a script to go through all data from a mouseFolderList and
% extract out useful summary data

mouseName = mouseFolderList{i,1};

mouseFolderPath = mouseFolderList{i,2};

cd(mouseFolderPath);

mouseDir = dir;

% go through mouse dir

% make avg tif image
ch = 0; endFr = 500;
tifStack = readMcTifStackSima(basename, ch, endFr);
avgTif = mean(tifStack,3);

%% user input soma/dend ('s' or 'd') based upon avgTif
somaDend = input('Somata (s) or Dend (d)?', 's');

%% get behav program name
binFilename = findLatestFilename('.bin');
behavBasename = binFilename(1:strfind(binFilename, '.bin')-1);
programName = readArduinoProgramName([behavBasename '.txt']);

%% load latest dendrite behav struc
dbsFilename = findLatestFilename('dendriteBehavStruc');
load(dbsFilename);



% compile dendriteBehavStruc fields
% NOTE: maybe recompute this because some things might have changed
% corr/incorr rew/unrew stim ind
% rew4
% rew5
% iso lick
% iso levPress/Lift?

dendriteBehavStruc.correctRewStimIndCa
correctUnrewStimIndCa

rewTime4Ca
rewTime5Ca
rewTime10Ca
itiLickTimeCa
itiLevPressTimeCa

%% calculate performance
sessSummStruc.binFracCorrect = binErrorRates(dendriteBehavStruc.eventStruc.correctRespStruc);

%% if no goodSeg, make quick auto goodSegs

% compile avg ca event kinetics for best units

%% compile whiskCa xcorr
% NOTE: this was not calculated consistently so I should recalculate
% fullSession
% ITIs
try
toPlot = 0;
[whiskCaXcorrStruc] = whiskCaEpochXCorrPS3(toPlot);
save([basename '_whiskCaXcorrStruc_' date], 'whiskCaXcorrStruc');
sessSummStruc.whCaXcorr.fullSessionXcorr = whiskCaXcorrStruc.fullSessionXcorr;
sessSummStruc.whCaXcorr.fullSessionXcorr = whiskCaXcorrStruc.fullSessionXcorr;

catch
    disp('Could not process whiskCaXcorr');
    
end


%% compile itiWhiskBoutCa
% go ahead and repeat anaylsis with new parameters
try
toSave = 1; toPlot = 0;
[itiWhiskBoutCaStruc] = itiWhiskBoutCaFrame(toSave, toPlot);
sessSummStruc.itiWhiskBoutCa
sessSummStruc.itiWhiskBoutAngle

catch
    disp('Could not process itiWhiskBoutCa');
end

% prob with times in this whisker data
% /home/clay/Documents/Data/2p mouse behavior/Rbp4/R14/mouseR141/2015-06-14/2015-06-14-001

save([  ], 'sessSummStruc');


