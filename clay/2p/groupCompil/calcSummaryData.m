function [sessSummStruc] = calcSummaryData();

fieldList = {'correctRewStimInd','correctUnrewStimInd',...
    'incorrectRewStimInd','incorrectUnrewStimInd',...
    'corrRewFirstContactTimes1','incorrRewFirstContactTimes1',...
    'rewTime','rewTime1','rewTime4','rewTime5','rewTime10',...
    'rewDelay1Time', 'rewDelay2Time', 'rewDelay3Time',...
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
disp('Recalculating dendriteBehavStruc');
tic;
tifName = [tifBasename '.tif'];
seg = 1; toProcess = 1;
[dendriteBehavStruc] = dendriteBehavAnalysisNameSeg(tifName, dayPath, seg, toProcess);
sessSummStruc.dendriteBehavStruc = dendriteBehavStruc;
toc;

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
disp('Calculating behav performance');
tic;
try
[binFracCorrect, binDiscInd, binFracRew, binFracUnrew] = binErrorRates(dendriteBehavStruc.eventStruc.correctRespStruc);
%sessSummStruc.binFracCorrect = binFracCorrect;
sessSummStruc.binDiscInd = binDiscInd;
%sessSummStruc.binFracRew = binFracRew; 
%sessSummStruc.binFracUnrew = binFracUnrew;
catch
    sessSummStruc.binDiscInd = [];
end
toc;

%% compile dendriteBehavStruc fields
disp('Compiling dendriteBehavStruc fields');
tic;
sessSummStruc = compileDbsFields(dendriteBehavStruc, sessSummStruc, fieldList);
toc;

%% if no goodSeg, make quick auto goodSegs

%% compile avg ca event kinetics for best units
disp('Compiling segStruc fields');
tic;
sessSummStruc = compileSegStrucFields(sessSummStruc, fieldList);
toc;



%% compile whiskCa xcorr
% NOTE: this was not calculated consistently so I should recalculate
% fullSession
% ITIs
disp('Processing whiskCaXcorr');
tic;
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
toc;

%% unitWhiskCa
disp('Processing unitWhiskXcorr');
tic;
try
forEpochs = 0; toPlot = 0;
[unitWhiskXcorrStruc] = whiskCaEpochXCorrPS3units(forEpochs, toPlot);
sessSummStruc.fullSessionXcorrUnits = unitWhiskXcorrStruc.fullSessionXcorrUnits;

catch
    disp('Could not process unitWhiskXcorr');
    sessSummStruc.fullSessionXcorrUnits = [];
end
toc;

%% compile itiWhiskBoutCa
% go ahead and repeat anaylsis with new parameters
disp('Processing itiWhiskBoutCa');
tic;
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
toc;

% prob with times in this whisker data
% /home/clay/Documents/Data/2p mouse behavior/Rbp4/R14/mouseR141/2015-06-14/2015-06-14-001

disp('Processing unitItiWhiskCa');
tic;
try
sessSummStruc.itiWhiskCaUnits = itiWhiskBoutCaUnit(itiWhiskBoutCaStruc);
catch
    disp('Could not process unitItiWhiskCa');
    sessSummStruc.itiWhiskCaUnits = [];
end
toc;

%% rewTrack/randRew analysis

disp('Processing unitRandRewTrack');
tic;
try
    [unitRandRewTrackStruc] = unitRandRewTrackSess();
sessSummStruc.unitRandRewTrackStruc = unitRandRewTrackStruc;
catch
    disp('Could not process unitRandRewTrack');
    sessSummStruc.unitRandRewTrackStruc = [];
end
toc;

%% Save output
save([tifBasename '_sessSummStruc_' date], 'sessSummStruc');

end

%% SUBFUNCTIONS

function sessSummStruc = compileDbsFields(dendriteBehavStruc, sessSummStruc, fieldList)


sessSummStruc.dbsStrucSub.dbsName = findLatestFilename('dendriteBehavStruc');

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

sessSummStruc.segStrucSub.segStrucName = segStrucName;

for i = 1:length(fieldList)
    try
    ca = segStruc.([fieldList{i} 'Ca']);
    roiHist = segStruc.([fieldList{i} 'RoiHist']);
    roiHist2 = segStruc.([fieldList{i} 'RoiHist2']);
    
    sessSummStruc.segStrucSub.([fieldList{i} 'Ca']) = ca(:,goodSeg, :);
    sessSummStruc.segStrucSub.([fieldList{i} 'RoiHist']) = roiHist(:,goodSeg);
    sessSummStruc.segStrucSub.([fieldList{i} 'RoiHist2']) = roiHist2(:,goodSeg);
    catch
        disp(['Couldnt find field: ' fieldList{i}]);
    end

end

end