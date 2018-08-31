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

[itiStruc] = findStimITIind(dendriteBehavStruc, x2);

itiBegInd = itiStruc.itiBegInd;
itiEndInd = itiStruc.itiEndInd;
stimEpBegInd = itiStruc.stimEpBegInd;
stimEpEndInd = itiStruc.stimEpEndInd;
itiBegInd2 = itiStruc.itiBegInd2;  % these are ITIs only between stims
itiEndInd2 = itiStruc.itiEndInd2;

%% trim whisker video to calcium beg/end times and interp Ca

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
frameAvgDf = dendriteBehavStruc.frameAvgDf;
tMs = frameTrig(1):frameTrig(end);

whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies
frTimes = whiskDataStruc.frTimes;

% only take whisking var from same period as frameAvgDf
whiskerData = whiskerData(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));
frTimes = frTimes(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));

% now interp whiskerData to ms
whiskerData = interp1(frTimes, whiskerData, tMs);
whiskerData(isnan(whiskerData)) = nanmean(whiskerData);

% interp frameAvgDf to ms
ca2 = interp1(frameTrig, frameAvgDf, tMs);
ca2(isnan(ca2)) = nanmean(ca2);

% okay now I have a little problem: because I trimmed the whisker video to
% the length of the calcium (NOTE: I may have trimmed a wee bit too much
% because I'm not taking into account the duration of the final 2p frame).
% I think the following might take care of this, BUT this might throw off
% the indexing of other things (because I'm not using the full length of
% the ms in .bin file). Might want to selct out stim/iti indices for good
% trials too. Or maybe just TRY/CATCH inside trial FOR loops to throw out
% bad trials and not mess up time indices...

% and correct epoch times based upon calcium
% itiBegInd = itiBegInd(itiBegInd>=frameTrig(1) && itiEndInd<frameTrig(end));
% itiEndInd = itiEndInd(itiBegInd>=frameTrig(1) && itiEndInd<frameTrig(end));
% stimEpBegInd = stimEpBegInd(stimEpBegInd>=frameTrig(1) && stimEpEndInd<frameTrig(end));
% stimEpEndInd = stimEpEndInd(stimEpBegInd>=frameTrig(1) && stimEpEndInd<frameTrig(end));
% itiBegInd2 = itiBegInd2(itiBegInd2>=frameTrig(1) && itiEndInd2<frameTrig(end));  % these are ITIs only between stims
% itiEndInd2 = itiEndInd2(itiBegInd2>=frameTrig(1) && itiEndInd2<frameTrig(end));

%% XCORR for these epochs (and plotting)

rewStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
unrewStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;

% now calculate xcorr for all these epochs
% 1.) all ITIs

r = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, itiBegInd2, itiEndInd2);

% figure;
% plot(mean(r,1), 'Color', [1 0 1]);
% hold on;

% 2.) all stim/catch epochs

r2 = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, stimEpBegInd, stimEpEndInd);

specStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
rewStimStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd; % 09105

%specStimInd = incorrectRewStimInd;

%clear r3;

begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);


% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);

% 3.) all stim epochs

r3 = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, begInd, endInd);

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
        try
        if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0
            n = n+1;
            itiCa = ca2(tMs>=begInd(trial) & tMs<=endInd(trial));
    itiWhisk = whiskerData(tMs>=begInd(trial) & tMs<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 3000, 'coeff');
        end
        catch
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
    try
    itiCa = ca2(tMs>=itiBegInd2(trial) & tMs<=itiEndInd2(trial));
    itiWhisk = whiskerData(tMs>=itiBegInd2(trial) & tMs<=itiEndInd2(trial));
    r(trial, :) = xcorr(itiCa, itiWhisk, 3000, 'coeff');
    catch
    end
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
            itiCa = ca2(tMs>=begInd(trial) & tMs<=endInd(trial));
    itiWhisk = whiskerData(tMs>=begInd(trial) & tMs<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 3000, 'coeff');
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
            itiCa = ca2(tMs>=begInd(trial) & tMs<=endInd(trial));
    itiWhisk = whiskerData(tMs>=begInd(trial) & tMs<=endInd(trial));
            r3(trial, :) = xcorr(itiCa, itiWhisk, 3000, 'coeff');
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
    try
    itiCa = ca2(tMs>=begInd(trial) & tMs<=endInd(trial));
    itiWhisk = whiskerData(tMs>=begInd(trial) & tMs<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 3000, 'coeff');
    catch
    end
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
    try
    itiCa = ca2(tMs>=begInd(trial) & tMs<=endInd(trial));
    itiWhisk = whiskerData(tMs>=begInd(trial) & tMs<=endInd(trial));
    r3(trial, :) = xcorr(itiCa, itiWhisk, 3000, 'coeff');
    catch
    end
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

r4 = xcorr(ca2, whiskerData', 3000, 'coeff');
whiskCaXCorrStruc.fullSession = r4;

if toPlot
    figure;
    plot(r4, 'Color', [1 0.5 0.2]);
    title([filename ' XCORR Ca2+ vs whiskerAngle ' date]);
end