function [sessSummStruc] = calcSummaryData();

fieldList = {'correctRewStimInd','correctUnrewStimInd',...
    'incorrectRewStimInd','incorrectUnrewStimInd',...
    'corrRewFirstContactTimes1','incorrRewFirstContactTimes1',...
    'rewTime','rewTime1','rewTime4','rewTime5','rewTime10',...
    'punTime1','itiLickTime','isoLickTime','itiLevLiftTime','isoLevLiftTime'};


%% Process mouse directory you're currently in
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

sessSummStruc = compileDbsFields(dendriteBehavStruc, sessSummStruc, fieldList);


%% if no goodSeg, make quick auto goodSegs

% compile avg ca event kinetics for best units


sessSummStruc = compileSegStrucFields(sessSummStruc, fieldList);




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

function sessSummStruc = compileDbsFields(dendriteBehavStruc, sessSummStruc, fieldList)


for i = 1:length(fieldList)
    try
    sessSummStruc.dbsStrucSub.([fieldList{i} 'Ca']) = dendriteBehavStruc.([fieldList{i} 'Ca']);
    catch
        disp(['Couldnt find field: ' fieldList{i} 'Ca']);
    end

end


end

%%
function sessSummStruc = compileSegStrucFields(sessSummStruc, fieldList)

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

for i = 1:length(fieldList)
    try
    sessSummStruc.segStrucSub.([fieldList{i} 'Ca']) = segStruc.([fieldList{i} 'Ca']);
    sessSummStruc.segStrucSub.([fieldList{i} 'RoiHist']) = segStruc.([fieldList{i} 'RoiHist']);
    sessSummStruc.segStrucSub.([fieldList{i} 'RoiHist2']) = segStruc.([fieldList{i} 'RoiHist2']);
    catch
        disp(['Couldnt find field: ' fieldList{i}]);
    end

end

end