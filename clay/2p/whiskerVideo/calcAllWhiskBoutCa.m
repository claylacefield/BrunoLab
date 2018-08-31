function [whiskBoutCa, whiskBoutVar] = calcAllWhiskBoutCa(rewStimFrames, sessionNames)

%% USAGE: [whiskBoutCa] = calcAllWhiskBoutCa(rewStimFrames, sessionNames);
% This script reads in all the relevant files for calculating whisking
% bout-triggered frame calcium and compiles 


whiskBoutCa = []; whiskBoutVar = [];

for sessInd = 1:size(sessionNames,2)
    
    load([sessionNames{1,sessInd} '_whiskData.mat']);
    totalFr = totalFr + 1; % just because I miscalculated earlier
    
    load([sessionNames{1,sessInd} '_rewStimAdjTime.mat']);
    [times, frRate] = calcWhiskFrameTimes(totalFr, rewStimAdjTime, rewStimFrames, sessInd);
    
    name = dir([sessionNames{2,sessInd}  '_dendriteBehavStruc_*.mat']);
    dbsName = name.name;
    load(dbsName);
    name = dir([sessionNames{2,sessInd}  '_frameAvgDf_*.mat']);
    fadName = name.name;
    load(fadName);
    [eventCa, cleanItiWhiskBoutSig] = itiWhiskBoutCaFrame(dendriteBehavStruc, frameAvgDf, meanAngle, times);
    
    whiskBoutCa = [whiskBoutCa eventCa];
    whiskBoutVar = [whiskBoutVar cleanItiWhiskBoutSig];
    
end