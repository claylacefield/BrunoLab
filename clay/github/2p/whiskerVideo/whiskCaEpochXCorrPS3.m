function [whiskCaXcorrStruc] = whiskCaEpochXCorrPS3(toPlot)

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
% in their entirety, based upon artifacts in behav signals
eventStruc = dendriteBehavStruc.eventStruc;
[itiStruc] = findStimITIind(eventStruc, x2);

itiBegTimes = itiStruc.itiBegTimes;
itiEndTimes = itiStruc.itiEndTimes;
stimEpBegTimes = itiStruc.stimEpBegTimes;
stimEpEndTimes = itiStruc.stimEpEndTimes;

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

% okay now I have a little problem: because I trimmed the whisker video to
% the length of the calcium (NOTE: I may have trimmed a wee bit too much
% because I'm not taking into account the duration of the final 2p frame).
% I think the following might take care of this, BUT this might throw off
% the indexing of other things (because I'm not using the full length of
% the ms in .bin file). Might want to selct out stim/iti indices for good
% trials too. Or maybe just TRY/CATCH inside trial FOR loops to throw out
% bad trials and not mess up time indices...

% and correct epoch times based upon calcium
% itiBegTimes = itiBegTimes(itiBegTimes>=frameTrig(1) && itiEndTimes<frameTrig(end));
% itiEndTimes = itiEndTimes(itiBegTimes>=frameTrig(1) && itiEndTimes<frameTrig(end));
% stimEpBegTimes = stimEpBegTimes(stimEpBegTimes>=frameTrig(1) && stimEpEndTimes<frameTrig(end));
% stimEpEndTimes = stimEpEndTimes(stimEpBegTimes>=frameTrig(1) && stimEpEndTimes<frameTrig(end));
% itiBegTimes2 = itiBegTimes2(itiBegTimes2>=frameTrig(1) && itiEndTimes2<frameTrig(end));  % these are ITIs only between stims
% itiEndTimes2 = itiEndTimes2(itiBegTimes2>=frameTrig(1) && itiEndTimes2<frameTrig(end));

%% XCORR for these epochs 


% now calculate xcorr for all these epochs
% NOTE 160409: now I'm calculating xcorr for all stim and ITI epochs and
% then selecting out particular stim/iti types for averages

% 1.) all ITIs
disp(['Calculating calcium/whisking xcorr for ' sessionName]); 
tic;
%allItiXcorr = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, itiBegTimes, itiEndTimes);
allItiXcorr = whiskCaEpochXCorrSingle(ca3, wd3, tMs, itiBegTimes, itiEndTimes);

% 2.) all stim/catch epochset
%allStimXcorr = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, stimEpBegTimes, stimEpEndTimes);
allStimXcorr = whiskCaEpochXCorrSingle(ca3, wd3, tMs, stimEpBegTimes, stimEpEndTimes);
toc;


%% Select xcorr for trials of particular types

rewStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
rewStimInd =  rewStimInd(rewStimInd <= size(allStimXcorr,1));
unrewStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
unrewStimInd =  unrewStimInd(unrewStimInd <= size(allStimXcorr,1));

rewStimXcorr = allStimXcorr(rewStimInd,:); %  <= size(allStimXcorr,1)), :);
unrewStimXcorr = allStimXcorr(unrewStimInd,:); %  <= size(allStimXcorr,1)), :);

%whiskCaXcorrStruc.rewStimXcorr =  rewStimXcorr;
%whiskCaXcorrStruc.unrewStimXcorr =  unrewStimXcorr;

correctRewStimInd = dendriteBehavStruc.eventStruc.correctRewStimInd;
correctRewStimInd =  correctRewStimInd(correctRewStimInd <= size(allStimXcorr,1));
correctRewXcorr = allStimXcorr(correctRewStimInd,:); % <= size(allStimXcorr,1)), :); 
if isempty(correctRewXcorr)
    correctRewXcorr =  NaN(1,6001);
end

%whiskCaXcorrStruc.correctRewXcorr =  correctRewXcorr;

incorrectRewStimInd = dendriteBehavStruc.eventStruc.incorrectRewStimInd;
incorrectRewStimInd =  incorrectRewStimInd(incorrectRewStimInd <= size(allStimXcorr,1));
incorrectRewXcorr = allStimXcorr(incorrectRewStimInd,:); % <= size(allStimXcorr,1)), :);
if isempty(incorrectRewXcorr)
   incorrectRewXcorr =   NaN(1,6001);
end

%whiskCaXcorrStruc.incorrectRewXcorr = incorrectRewXcorr;

correctUnrewStimInd = dendriteBehavStruc.eventStruc.correctUnrewStimInd;
correctUnrewStimInd =  correctUnrewStimInd(correctUnrewStimInd <= size(allStimXcorr,1));
correctUnrewXcorr = allStimXcorr(correctUnrewStimInd,:); % <= size(allStimXcorr,1)), :); 
if isempty(correctUnrewXcorr)
correctUnrewXcorr =  NaN(1,6001);
end

%whiskCaXcorrStruc.correctUnrewXcorr = correctUnrewXcorr;

incorrectUnrewStimInd = dendriteBehavStruc.eventStruc.incorrectUnrewStimInd;
incorrectUnrewStimInd =  incorrectUnrewStimInd(incorrectUnrewStimInd <= size(allStimXcorr,1));
incorrectUnrewXcorr = allStimXcorr(incorrectUnrewStimInd,:); % <= size(allStimXcorr,1)), :); 
if isempty(incorrectUnrewXcorr)
    incorrectUnrewXcorr =  NaN(1,6001);
end

%whiskCaXcorrStruc.incorrectUnrewXcorr = incorrectUnrewXcorr;

%% now for ITIs of particular types

try
    rewTime4 = dendriteBehavStruc.eventStruc.rewTime4;
    %n=0;
    
    for numIti = 1:length(itiBegTimes)
        for numRew4 = 1:length(rewTime4)
            if rewTime4(numRew4)> itiBegTimes(numIti) && rewTime4(numRew4) < itiEndTimes(numIti)
                randRewItiInd(numRew4) = numIti;
                %        else
                %            n = n + 1;
                %            normalItiInd(n) = numIti;
            end
        end
    end
    
    normalItiInd = 1:length(itiBegTimes);
    normalItiInd = setxor(normalItiInd, randRewItiInd);
    
    % try
    randRewItiXcorr = allItiXcorr(randRewItiInd,:);
    normalItiXcorr = allItiXcorr(normalItiInd,:);
    whiskCaXcorrStruc.randRewItiXcorr = randRewItiXcorr';
    whiskCaXcorrStruc.normalItiXcorr = normalItiXcorr';
catch
    disp('No randRew in this session');
    whiskCaXcorrStruc.randRewItiXcorr = NaN(1,6001);
    whiskCaXcorrStruc.normalItiXcorr = allItiXcorr';
end

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

whiskCaXcorrStruc.allStimXcorr = allStimXcorr';
whiskCaXcorrStruc.allItiXcorr = allItiXcorr';

whiskCaXcorrStruc.rewStimXcorr = rewStimXcorr';
whiskCaXcorrStruc.unrewStimXcorr = unrewStimXcorr';

whiskCaXcorrStruc.correctRewXcorr = correctRewXcorr'; 
whiskCaXcorrStruc.incorrectRewXcorr = incorrectRewXcorr';

whiskCaXcorrStruc.correctUnrewXcorr = correctUnrewXcorr'; 
whiskCaXcorrStruc.incorrectUnrewXcorr = incorrectUnrewXcorr';

%% new 041316
if itiEndTimes(end)-itiBegTimes(end) > 10000
lastItiXcorr = allItiXcorr(end, :);
end
whiskCaXcorrStruc.lastItiXcorr = lastItiXcorr';

try
n=0;
for numTrial = 1:length(itiBegTimes)
    if length(itiEndTimes(numTrial)-itiBegTimes(numTrial)) > 10000
        n=n+1;
        longItiXcorr(n,:) = allItiXcorr(numTrial,:);
    end    
end

whiskCaXcorrStruc.longItiXcorr = longItiXcorr';

catch
disp('No long (>10s) ITIs');
whiskCaXcorrStruc.longItiXcorr = NaN(1,6001)';
end