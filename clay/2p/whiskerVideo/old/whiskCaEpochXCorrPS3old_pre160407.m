function [whiskCaXCorrStruc] = whiskCaEpochXCorrPS3(toPlot)

% clay Sep. 19, 2015

%% Load in all necessary structures in session directory
sessionDir = dir;

sessionDirNames = {sessionDir.name};

whiskDataStrucName = sessionDir(find(cellfun(@length, strfind(sessionDirNames, 'whiskDataStruc')))).name;
load(whiskDataStrucName);

sessionName = whiskDataStrucName(1:14);

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

% identify epochs based upon behav sig

% NOTE: remember that there are some datasets with weird
% small start signals, so may have to account for this
% if I want to generalize

startSig = x2(8,:);  % NOTE: now using pun signals because less contam.

maxV = max(startSig);

% and use rewSig if startSig is weird small one
if maxV < 3
    
    startSig = x2(3,:);
    maxV = max(startSig);
end

rmStart = runmean(startSig, 10);  % smooth out startSig

[counts, centers] = hist(rmStart, 100);  % find distrib of voltages

% find threshold for hist peaks based upon number of trials

numTrials = length(dendriteBehavStruc.eventStruc.stimTrigTime);
histPkThresh = numTrials*200;

vStartPks = LocalMinima(-counts, 5, -histPkThresh); % find common voltages (iti baseline, startTrig val, stim artif val, stim/catch baseline)

pkV = centers(vStartPks);  % find common voltage val (lower = iti, higher = trials)
% NOTE: only taking the lower vale, i.e. not the TTL signal, for shift in
% baseline with stim onset
pkCounts = counts(vStartPks);  % and how common

[newCounts, newOrder] = sort(pkCounts);  % sort least common (stim artifact) to most common (iti or stim epoch)

%stimArtVal = pkV(newOrder(1));

% actually, going to base everything upon iti indices
itiVal = pkV(1);

% find indices of putative iti based upon being close to low voltage peak
itiInd = find(abs(rmStart-itiVal) < (pkV(2)-pkV(1))/2);

% plot begin and ends of iti's
%figure; plot(rmStart);
%hold on;
%plot(t(itiInd), rmStart(itiInd), 'r.');

% find iti based upon big gaps between iti indices
itiEndInd = itiInd(find(diff(itiInd)>1000));
t = 1:length(rmStart);
%plot(t(itiEndInd), rmStart(itiEndInd), 'y.');

% and likewise for iti end
itiBegInd = itiInd(find(diff(itiInd)>1000) + 1);

%plot(t(itiBegInd), rmStart(itiBegInd), 'm.');

% find stim epochs based upon iti's (between stim movements)
stimEpBegInd = itiEndInd +170;
stimEpEndInd = itiBegInd -270;

% and then adjust iti with beginning and ending points
% itiEndInd2 = [itiEndInd length(rmStart)];
% itiBegInd2 = [1 itiBegInd];
% OR just count ITIs between trials (i.e. not initial and final periods)
itiEndInd2 = itiEndInd(2:end);
itiBegInd2 = itiBegInd(1:end-1);


%% trim whisker video to calcium beg/end times and interp Ca

rewStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
unrewStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
frameAvgDf = dendriteBehavStruc.frameAvgDf;

whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies
frTimes = whiskDataStruc.frTimes;

% only take whisking var from same period as frameAvgDf
whiskerData = whiskerData(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));
frTimes = frTimes(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));

% interp frameAvgDf to whisker imaging frame times
ca2 = interp1(frameTrig, frameAvgDf, frTimes);


%% XCORR for these epochs (and plotting)

% now calculate xcorr for all these epochs
% 1.) all ITIs
for trial = 1:length(itiBegInd2)
    itiCa = ca2(frTimes>=itiBegInd2(trial) & frTimes<=itiEndInd2(trial));
    itiWhisk = whiskerData(frTimes>=itiBegInd2(trial) & frTimes<=itiEndInd2(trial));
    r(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
end

% figure;
% plot(mean(r,1), 'Color', [1 0 1]);
% hold on;

% 2.) all stim/catch epochs
for trial = 1:length(stimEpBegInd)
    itiCa = ca2(frTimes>=stimEpBegInd(trial) & frTimes<=stimEpEndInd(trial));
    itiWhisk = whiskerData(frTimes>=stimEpBegInd(trial) & frTimes<=stimEpEndInd(trial));
    r2(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
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
    itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
    itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
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
try
    for trial = 1:length(begInd)
        
        if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0
            n = n+1;
            itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
            itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
            r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
        end
    end
    
    if toPlot
        hold on;
        plot(mean(r3,1), 'Color', [0 1 0]);
    end
    
catch
    disp('no random reward epochs');
end

legend('all ITIs', 'stim/catch trial epochs', 'rew stim epochs', 'randRew ITIs');
title(filename);
%end
% itiBegInd3 = itiBegInd2 + 500;
% itiEndInd3 = itiEndInd2 - 500;


%%%%%%%%%%%%%%%%%%%%%%%%
% RUN THE BELOW TO CREATE GRAPHS LIKE SAVED FOR ITI


% 1.) all ITIs
for trial = 1:length(itiBegInd2)
    itiCa = ca2(frTimes>=itiBegInd2(trial) & frTimes<=itiEndInd2(trial));
    itiWhisk = whiskerData(frTimes>=itiBegInd2(trial) & frTimes<=itiEndInd2(trial));
    r(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
end

if toPlot
    figure; hold on;
    plot(mean(r,1), 'Color', [1 0 1]);
end

whiskCaXCorrStruc.allITIs = mean(r,1);

% 2.) randRew ITIs
begInd = itiBegInd2; %(specStimInd);
endInd = itiEndInd2; %(specStimInd);
n = 0; clear r3;

try
    for trial = 1:length(begInd)
        if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))==0
            n = n+1;
            itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
            itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
            r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
        end
    end
    
    if toPlot
        plot(mean(r3,1), 'Color', [1 0 0]);
    end
catch
end

try
    whiskCaXCorrStruc.randRewITIs = mean(r3,1);
catch
    whiskCaXCorrStruc.randRewITIs = NaN(2001,1);
end

% n = 0; clear r3;
% for trial = 1:length(begInd)
% if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>0
% n = n+1;
% itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
% itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
% r3(trial, :) = xcorr(itiCa, itiWhisk, 1000);
% end
% end
% hold on;
% plot(mean(r3,1), 'Color', [1 1 0]);


% 3.) conserv randRew ITIs (not including early and late part of ITIs)
begInd = itiBegInd3; %(specStimInd);
endInd = itiEndInd3; %(specStimInd);
n = 0; clear r3;

try
    for trial = 1:length(begInd)
        if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0
            n = n+1;
            itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
            itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
            r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
        end
    end
    % hold on;
    if toPlot
        plot(mean(r3,1), 'Color', [0 1 0]);
    end
catch
end

% 4.) catch trial epochs
specStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
%specStimInd = incorrectRewStimInd;
specStimInd = specStimInd(specStimInd<=length(stimEpBegInd));
clear r3;
begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);
% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);
for trial = 1:length(begInd)
    itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
    itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
end

if toPlot
    plot(mean(r3,1), 'Color','c');
end
whiskCaXCorrStruc.catchTrials = mean(r3,1);

% 5.) stim trial epochs
specStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
%specStimInd = incorrectRewStimInd;
clear r3;
begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);
% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);
for trial = 1:length(begInd)
    itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
    itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
end

if toPlot
    plot(mean(r3,1), 'Color','b');
end

whiskCaXCorrStruc.stimTrials = mean(r3,1);

% 6.) ITIs after correct rew stim
% ind = correctRewStimInd + 1;
%
% begInd = itiBegInd2(ind);
% endInd = itiEndInd2(ind);
% n = 0; clear r3;
% for trial = 1:length(begInd)
%     if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))==0
%         n = n+1;
%         itiCa = ca2(frTimes>=begInd(trial) & frTimes<=endInd(trial));
%         itiWhisk = whiskerData(frTimes>=begInd(trial) & frTimes<=endInd(trial));
%         r3(trial, :) = xcorr(itiCa, itiWhisk, 1000, 'coeff');
%     end
% end

if toPlot
    %     plot(mean(r3,1), 'Color',[0.3 0.3 0.3]);
    
    legend('all ITIs', 'randRew ITIs', 'conserv ITIs', 'catch trials', 'stim trials', 'ITIs after correct GO');
    title(filename);
end


whiskCaXCorrStruc.frameRate = round(1000/mean(diff(frTimes)));

%%

r4 = xcorr(ca2, whiskerData', 1000, 'coeff');
whiskCaXCorrStruc.fullSession = r4;

if toPlot
    figure;
    plot(r4, 'Color', [1 0.5 0.2]);
    title([filename ' XCORR Ca2+ vs whiskerAngle ' date]);
end