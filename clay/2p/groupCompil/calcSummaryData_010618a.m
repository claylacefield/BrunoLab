function [sessSummStruc] = calcSummaryData();


currPath = pwd;
sl = strfind(currPath, '/');
tifBasename = currPath(sl(end)+1:end);
dayPath = currPath(1:sl(end));
sessSummStruc.tifBasename = tifBasename;
sessSummStruc.sessPath = currPath;

tifDir = dir;
tifDirNames = {tifDir.name};

if ~exist([tifBasename '_somaDendTif.mat'])

%% make avg tif image
ch = 0; endFr = 100;
tifStack = readMcTifStackSima(tifBasename, ch, endFr);
avgTif = mean(tifStack,3);
avgTif = avgTif/max(avgTif(:));
sessSummStruc.avgTif = avgTif;
clear tifStack;
figure; imagesc(avgTif);
title(currPath);

%% user input soma/dend ('s' or 'd') based upon avgTif
somaDend = input('Somata (s) or Dend (d)?', 's');
sessSummStruc.somaDend = somaDend;
save([tifBasename '_somaDendTif'], 'somaDend', 'avgTif');

else
    load([tifBasename '_somaDendTif']);
    sessSummStruc.avgTif = avgTif;
    sessSummStruc.somaDend = somaDend;
end

%% get behav program name
binFilename = findLatestFilename('.bin');
behavBasename = binFilename(1:strfind(binFilename, '.bin')-1);
disp(['Behav basename ' behavBasename]);
try
    [programName, rewDir] = readArduinoProgramNameRewDir([behavBasename '.txt']);
    sessSummStruc.programName = programName;
    sessSummStruc.rewDir = rewDir;
    
    if strfind(programName, 'ick')
        sessSummStruc.levLick = 2; % for lick choice
    else
        sessSummStruc.levLick = 1; % for lever choice
    end
    
catch
    sessSummStruc.programName = 'prob old stage1';
    sessSummStruc.rewDir = 0;
end

%% load latest dendrite behav struc
% dbsFilename = findLatestFilename('dendriteBehavStruc');
% load(dbsFilename);

% or reprocess
tifName = [tifBasename '.tif'];
seg = 1; toProcess = 1;
[dendriteBehavStruc] = dendriteBehavAnalysisNameSeg(tifName, dayPath, seg, toProcess);
sessSummStruc.dendriteBehavStruc = dendriteBehavStruc;

% get ca framerate
frameTrig = dendriteBehavStruc.eventStruc.frameTrig; 
empCaFps = 1000/mean(diff(frameTrig));
if empCaFps < 3
    caFps = 2;
elseif empCaFps > 6
    caFps = 8;
else
    caFps = 4;
end
sessSummStruc.caFps = caFps;


%% calculate performance
try
[binFracCorrect, binDiscInd, binFracRew, binFracUnrew] = binErrorRates(dendriteBehavStruc.eventStruc.correctRespStruc);
%sessSummStruc.binFracCorrect = binFracCorrect;
sessSummStruc.binDiscInd = binDiscInd;
%sessSummStruc.binFracRew = binFracRew; 
%sessSummStruc.binFracUnrew = binFracUnrew;
catch
    sessSummStruc.binDiscInd = [];
end

%% compile dendriteBehavStruc fields

sessSummStruc = compileDbsFields(dendriteBehavStruc, sessSummStruc);


%% if no goodSeg, make quick auto goodSegs

% compile avg ca event kinetics for best units


sessSummStruc = compileSegStrucFields(sessSummStruc);




%% compile whiskCa xcorr
% NOTE: this was not calculated consistently so I should recalculate
% fullSession
% ITIs
try
toPlot = 0;
[whiskCaXcorrStruc] = whiskCaEpochXCorrPS3(toPlot);
save([tifBasename '_whiskCaXcorrStruc_' date], 'whiskCaXcorrStruc');
%sessSummStruc.whCaXcorr.fullSessionXcorr = whiskCaXcorrStruc.fullSessionXcorr;
sessSummStruc.fullSessionXcorr = whiskCaXcorrStruc.fullSessionXcorr;

catch
    disp('Could not process whiskCaXcorr');
    sessSummStruc.fullSessionXcorr = [];
end

%% unitWhiskCa

try
forEpochs = 0; toPlot = 0;
[unitWhiskXcorrStruc] = whiskCaEpochXCorrPS3units(forEpochs, toPlot);
sessSummStruc.fullSessionXcorrUnits = unitWhiskXcorrStruc.fullSessionXcorrUnits;

catch
    disp('Could not process unitWhiskXcorr');
    sessSummStruc.fullSessionXcorrUnits = [];
end

%% compile itiWhiskBoutCa
% go ahead and repeat anaylsis with new parameters
try
toSave = 1; toPlot = 0;
[itiWhiskBoutCaStruc] = itiWhiskBoutCaFrame(toSave, toPlot);
sessSummStruc.itiWhiskBoutCa = itiWhiskBoutCaStruc.itiWhiskBoutCa;
sessSummStruc.itiWhiskBoutAngle = itiWhiskBoutCaStruc.itiWhiskBoutAngle;
sessSummStruc.itiWhiskBoutCaStruc = itiWhiskBoutCaStruc;

catch
    disp('Could not process itiWhiskBoutCa');
    sessSummStruc.itiWhiskBoutCa = [];
    sessSummStruc.itiWhiskBoutAngle = [];
    sessSummStruc.itiWhiskBoutCaStruc = [];
end

% prob with times in this whisker data
% /home/clay/Documents/Data/2p mouse behavior/Rbp4/R14/mouseR141/2015-06-14/2015-06-14-001


try
sessSummStruc.itiWhiskCaUnits = itiWhiskBoutCaUnit(itiWhiskBoutCaStruc);
catch
    disp('Could not process unitItiWhiskCa');
    sessSummStruc.itiWhiskCaUnits = [];
end


%% Save output
save([tifBasename '_sessSummStruc_' date], 'sessSummStruc');

end

%% SUBFUNCTIONS

function sessSummStruc = compileDbsFields(dendriteBehavStruc, sessSummStruc)

% NOTE: maybe recompute this because some things might have changed
% corr/incorr rew/unrew stim ind
% rew4
% rew5
% iso lick
% iso levPress/Lift?

try
    sessSummStruc.correctRewStimIndCa = dendriteBehavStruc.correctRewStimIndCa;
catch
    sessSummStruc.correctRewStimIndCa = [];
end
try
    sessSummStruc.correctUnrewStimIndCa = dendriteBehavStruc.correctUnrewStimIndCa;
catch
    sessSummStruc.correctUnrewStimIndCa = [];
end

try
    sessSummStruc.corrRewFirstContactTimes1Ca = dendriteBehavStruc.corrRewFirstContactTimes1Ca;
catch
    sessSummStruc.corrRewFirstContactTimes1Ca = [];
end

try
    sessSummStruc.incorrRewFirstContactTimes1Ca = dendriteBehavStruc.incorrRewFirstContactTimes1Ca;
catch
    sessSummStruc.incorrRewFirstContactTimes1Ca = [];
end

try
    sessSummStruc.rewTimeCa = dendriteBehavStruc.rewTimeCa;
catch
    sessSummStruc.rewTimeCa = [];
end

try
    sessSummStruc.rewTime1Ca = dendriteBehavStruc.rewTime1Ca;
catch
    sessSummStruc.rewTime1Ca = [];
end

try
    sessSummStruc.rewTime4Ca = dendriteBehavStruc.rewTime4Ca;
catch
    sessSummStruc.rewTime4Ca = [];
end
try
    sessSummStruc.rewTime5Ca = dendriteBehavStruc.rewTime5Ca;
catch
    sessSummStruc.rewTime5Ca = [];
end

try
    sessSummStruc.rewTime10Ca = dendriteBehavStruc.rewTime10Ca;
catch
    sessSummStruc.rewTime10Ca = [];
end

try
    sessSummStruc.punTime1Ca = dendriteBehavStruc.punTime1Ca;
catch
    sessSummStruc.punTime1Ca = [];
end

try
    sessSummStruc.itiLickTimeCa = dendriteBehavStruc.itiLickTimeCa;
catch
    sessSummStruc.itiLickTimeCa = [];
end

try
    sessSummStruc.isoLickTimeCa = dendriteBehavStruc.isoLickTimeCa;
catch
    sessSummStruc.isoLickTimeCa = [];
end

try
    sessSummStruc.itiLevLiftTimeCa = dendriteBehavStruc.itiLevLiftTimeCa;
catch
    sessSummStruc.itiLevLiftTimeCa = [];
end

try
    sessSummStruc.isoLevLiftTimeCa = dendriteBehavStruc.isoLevLiftTimeCa;
catch
    sessSummStruc.isoLevLiftTimeCa = [];
end


end

function sessSummStruc = compileSegStrucFields(sessSummStruc)

try
goodSegName = findLatestFilename('_goodSeg_');
load(goodSegName);
sessSummStruc.goodSeg = goodSeg;
catch
disp('No goodSegs selected');    
goodSeg = 1:100;
end

segStrucName = findLatestFilename('_seg_');
load(segStrucName);

fieldList = {'correctRewStimIndCa','correctUnrewStimIndCa',...
    'corrRewFirstContactTimes1Ca','incorrRewFirstContactTimes1Ca',...
    'rewTimeCa','rewTime1Ca','rewTime4Ca','rewTime5Ca','rewTime10Ca',...
    'punTime1Ca','itiLickTimeCa','isoLickTimeCa','itiLevLiftTimeCa','isoLevLiftTimeCa'};

for i = 1:length(fieldList)
    sessSummStruc.dbsStrucSub.(fieldList{i}) = dendriteBehavStruc.(fieldList{i});

end