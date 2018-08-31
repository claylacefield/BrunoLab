function [whiskCaXcorrStruc] = whiskCaEpochXCorrPS3stage1(toPlot)

% clay Sep. 19, 2015

%% Load in all necessary structures in session directory
sessionDir = dir;

sessionDirNames = {sessionDir.name};

whiskDataStrucName = findLatestFilename('whiskDataStruc');
load(whiskDataStrucName);

sessionName = whiskDataStrucName(1:strfind(whiskDataStrucName, 'whisk')-2);

dbsName = findLatestFilename('dendriteBehavStruc');
load(dbsName);


binFilename = sessionDir(find(cellfun(@length, strfind(sessionDirNames, '.bin')))).name;
x2 = binRead2pSingleName(binFilename);

filename = sessionName;%dendriteBehavStruc.filename;

whiskCaXcorrStruc.sessionName = sessionName;
whiskCaXcorrStruc.date = date;
whiskCaXcorrStruc.dbsName = dbsName;
whiskCaXcorrStruc.whiskDataStrucName = whiskDataStrucName;

%% IDENTIFY STIM/ITI EPOCHS
% not for stage1

%% trim whisker video to calcium beg/end times and interp Ca

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
frameAvgDf = dendriteBehavStruc.frameAvgDf;
tMs = frameTrig(1):frameTrig(end);  % time in ms of 2p imaging

whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies
frTimes = whiskDataStruc.frTimes;

% only take whisking var from same period as frameAvgDf
whiskerData = whiskerData(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));
frTimes = frTimes(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));

% now interp whiskerData to ms
whiskerData = interp1(frTimes, whiskerData, tMs);
whiskerData(isnan(whiskerData)) = nanmean(whiskerData);  % think this is to eliminate possible NaNs and replace with mean of signal
wd3 = (whiskerData - mean(whiskerData))/std(whiskerData);

% interp frameAvgDf to ms
ca2 = interp1(frameTrig, frameAvgDf, tMs);
ca2(isnan(ca2)) = nanmean(ca2);
ca3 = (ca2-mean(ca2))/std(ca2);


%% Full session Xcorr

fullSessionXcorr = xcorr(ca3, wd3', 3000, 'coeff');
whiskCaXcorrStruc.fullSessionXcorr = fullSessionXcorr';


%% Plotting 

if toPlot
    figure;
    plot(fullSessionXcorr, 'Color', [1 0.5 0.2]);
    title([filename ' XCORR Ca2+ vs whiskerAngle ' date]);
end


%% build output structure

% whiskCaXcorrStruc.allStimXcorr = allStimXcorr';
% whiskCaXcorrStruc.allItiXcorr = allItiXcorr';
% 
% whiskCaXcorrStruc.rewStimXcorr = rewStimXcorr';
% whiskCaXcorrStruc.unrewStimXcorr = unrewStimXcorr';
% 
% whiskCaXcorrStruc.correctRewXcorr = correctRewXcorr'; 
% whiskCaXcorrStruc.incorrectRewXcorr = incorrectRewXcorr';
% 
% whiskCaXcorrStruc.correctUnrewXcorr = correctUnrewXcorr'; 
% whiskCaXcorrStruc.incorrectUnrewXcorr = incorrectUnrewXcorr';

%% new 041316
% if itiEndTimes(end)-itiBegTimes(end) > 10000
% lastItiXcorr = allItiXcorr(end, :);
% end
% whiskCaXcorrStruc.lastItiXcorr = lastItiXcorr';
% 
% try
% n=0;
% for numTrial = 1:length(itiBegTimes)
%     if length(itiEndTimes(numTrial)-itiBegTimes(numTrial)) > 10000
%         n=n+1;
%         longItiXcorr(n,:) = allItiXcorr(numTrial,:);
%     end    
% end
% 
% whiskCaXcorrStruc.longItiXcorr = longItiXcorr';
% 
% catch
% disp('No long (>10s) ITIs');
% whiskCaXcorrStruc.longItiXcorr = NaN(1,6001)';
% end