function [lickCaXCorrStruc] = lickCaEpochXCorr(toPlot)

% clay Sep. 21, 2015
% This is taken from whiskCaEpochXCorrPS3eye.m


%% Load in all necessary structures in session directory
sessionDir = dir;

sessionDirNames = {sessionDir.name};

% whiskDataStrucName = sessionDir(find(cellfun(@length, strfind(sessionDirNames, 'whiskDataStruc')))).name;
% load(whiskDataStrucName);

% sessionName = whiskDataStrucName(1:14);

dbsInd = find(cellfun(@length, strfind(sessionDirNames, 'dendriteBehavStruc')));
dbsDatenums = [sessionDir(dbsInd).datenum];
[lsaMax, lastInd] = max(dbsDatenums);
latestDbsInd = dbsInd(lastInd);
load(sessionDir(latestDbsInd).name);


binFilename = sessionDir(find(cellfun(@length, strfind(sessionDirNames, '.bin')))).name;
x2 = binRead2pSingleName(binFilename);

filename = dendriteBehavStruc.filename;

%% IDENTIFY STIM/ITI EPOCHS
% in their entirety, based upon artifacts in behav signals

[itiStruc] = findStimITIind(dendriteBehavStruc, x2);

itiEndInd = itiStruc.itiEndInd;
itiBegInd = itiStruc.itiBegInd;

stimEpBegInd = itiStruc.stimEpBegInd;
stimEpEndInd = itiStruc.stimEpEndInd;

itiEndInd2 = itiStruc.itiEndInd2;
itiBegInd2 = itiStruc.itiBegInd2;


%% trim whisker video to calcium beg/end times and interp Ca

rewStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
unrewStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
frameAvgDf = dendriteBehavStruc.frameAvgDf;

ca2 = frameAvgDf;

% now run script to calculate lick rates 
[lickRate] = calcLickRate(dendriteBehavStruc);

%% XCORR for these epochs (and plotting)

% now calculate xcorr for all these epochs
% 1.) all ITIs
for trial = 1:length(itiBegInd2)
    itiCa = ca2(frameTrig>=itiBegInd2(trial) & frameTrig<=itiEndInd2(trial));
    itiLick = lickRate(frameTrig>=itiBegInd2(trial) & frameTrig<=itiEndInd2(trial));
    r(trial, :) = xcorr(itiCa, itiLick, 20);
end

% figure;
% plot(nanmean(r,1), 'Color', [1 0 1]);
% hold on;

% 2.) all stim/catch epochs
for trial = 1:length(stimEpBegInd)
    itiCa = ca2(frameTrig>=stimEpBegInd(trial) & frameTrig<=stimEpEndInd(trial));
    itiLick = lickRate(frameTrig>=stimEpBegInd(trial) & frameTrig<=stimEpEndInd(trial));
    r2(trial, :) = xcorr(itiCa, itiLick, 20);
end

specStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
rewStimStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd; % 09105

%specStimInd = incorrectRewStimInd;

%clear r3;

begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);


% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);

% 3.) all stim epochs
for trial = 1:length(begInd)
    itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
    itiLick = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiLick, 20);
end

%plot(mean(r3,1), 'Color','b');

if toPlot
    figure;
    plot(mean(r,1), 'Color', [1 0 1]);
    hold on;
    plot(mean(r2,1), 'm');
    plot(mean(r3,1), 'y');
    legend('all ITIs', 'all stim/catch epochs', 'all rew stim trials');
    title(filename);
end

% for 2014-09-13-001 I thought the incorrectRewStimInd was wrong
% but it turns out that correctRewStimInd just doesn't include
% sol- (rew5) conditions. Thus doing the below gives you xcorr for
% rewStim with no rew for this animal

correctRewStimInd = dendriteBehavStruc.eventStruc.correctRewStimInd; % 091015

incorrectRewStimInd = rewStimStimInd(find(~ismember(rewStimStimInd, correctRewStimInd)));


rewTime4 = dendriteBehavStruc.eventStruc.rewTime4;

itiBegInd3 = itiBegInd2 + 500;
itiEndInd3 = itiEndInd2 - 500;

begInd = itiBegInd3; %(specStimInd);
endInd = itiEndInd3; %(specStimInd);


n = 0; clear r3;

% 4.) middle of randRew ITI period (not including early and late ITI)
for trial = 1:length(begInd)
    
    if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0
        n = n+1;
        itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
        itiLick = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
        r3(trial, :) = xcorr(itiCa, itiLick, 20);
    end
end

if toPlot
    hold on;
    plot(mean(r3,1), 'Color', [0 1 0]);


legend('all ITIs', 'stim/catch trial epochs', 'rew stim epochs', 'randRew ITIs');
title(filename);
end
% itiBegInd3 = itiBegInd2 + 500;
% itiEndInd3 = itiEndInd2 - 500;


%%%%%%%%%%%%%%%%%%%%%%%%
% RUN THE BELOW TO CREATE GRAPHS LIKE SAVED FOR ITI


% 1.) all ITIs
for trial = 1:length(itiBegInd2)
    itiCa = ca2(frameTrig>=itiBegInd2(trial) & frameTrig<=itiEndInd2(trial));
    itiLick = lickRate(frameTrig>=itiBegInd2(trial) & frameTrig<=itiEndInd2(trial));
    r(trial, :) = xcorr(itiCa, itiLick, 20);
end

if toPlot
    figure; hold on;
    plot(mean(r,1), 'Color', [1 0 1]);
end

lickCaXCorrStruc.allITIs = mean(r,1);

% 2.) randRew ITIs
begInd = itiBegInd2; %(specStimInd);
endInd = itiEndInd2; %(specStimInd);
n = 0; clear r3;
for trial = 1:length(begInd)
    if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))==0
        n = n+1;
        itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
        itiLick = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
        r3(trial, :) = xcorr(itiCa, itiLick, 20);
    end 
end

if toPlot
    plot(mean(r3,1), 'Color', [1 0 0]);
end

try
    lickCaXCorrStruc.randRewITIs = mean(r3,1);
catch
    lickCaXCorrStruc.randRewITIs = NaN(41,1);
end

% n = 0; clear r3;
% for trial = 1:length(begInd)
% if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>0
% n = n+1;
% itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
% itiWhisk = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
% r3(trial, :) = xcorr(itiCa, itiWhisk, 1000);
% end
% end
% hold on;
% plot(mean(r3,1), 'Color', [1 1 0]);


% 3.) conserv randRew ITIs (not including early and late part of ITIs)
begInd = itiBegInd3; %(specStimInd);
endInd = itiEndInd3; %(specStimInd);
n = 0; clear r3;
for trial = 1:length(begInd)
    if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0
        n = n+1;
        itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
        itiLick = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
        r3(trial, :) = xcorr(itiCa, itiLick, 20);
    end
end 
% hold on;
if toPlot
    plot(mean(r3,1), 'Color', [0 1 0]);
end


% 4.) catch trial epochs
specStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
%specStimInd = incorrectRewStimInd;
clear r3;
begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);
% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);
for trial = 1:length(begInd)
    itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
    itiLick = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiLick, 20);
end

if toPlot
    plot(mean(r3,1), 'Color','c');
end
lickCaXCorrStruc.catchTrials = mean(r3,1);

% 5.) stim trial epochs
specStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
%specStimInd = incorrectRewStimInd;
clear r3;
begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);
% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);
for trial = 1:length(begInd)
    itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
    itiLick = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiLick, 20);
end

if toPlot
    plot(mean(r3,1), 'Color','b');
end

lickCaXCorrStruc.stimTrials = mean(r3,1);

% 6.) ITIs after correct rew stim
% ind = correctRewStimInd + 1;
% 
% begInd = itiBegInd2(ind);
% endInd = itiEndInd2(ind);
% n = 0; clear r3;
% for trial = 1:length(begInd)
%     if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))==0
%         n = n+1;
%         itiCa = ca2(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
%         itiWhisk = lickRate(frameTrig>=begInd(trial) & frameTrig<=endInd(trial));
%         r3(trial, :) = xcorr(itiCa, itiWhisk, 20, 'coeff');
%     end
% end

if toPlot
%     plot(mean(r3,1), 'Color',[0.3 0.3 0.3]);
    
    legend('all ITIs', 'randRew ITIs', 'conserv ITIs', 'catch trials', 'stim trials', 'ITIs after correct GO');
    title(filename);
end


lickCaXCorrStruc.frameRate = round(1000/mean(diff(frameTrig)));

%%

r4 = xcorr(ca2, lickRate', 20);
lickCaXCorrStruc.fullSession = r4;

if toPlot
    figure;
    plot(r4, 'Color', [1 0.5 0.2]);
    title([filename ' XCORR Ca2+ vs whiskerAngle ' date]);
end