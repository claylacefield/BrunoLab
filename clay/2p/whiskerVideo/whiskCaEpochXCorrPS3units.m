function [unitWhiskXcorrStruc] = whiskCaEpochXCorrPS3units(forEpochs, toPlot);

% USAGE: [unitWhiskXcorrStruc] = whiskCaEpochXCorrPS3units(forEpochs, toPlot);
% Clay 010218
% forEpochs = 1; % then process all stim/ITI epochs (else just
% fullSessionXcorr)

%% Load in all necessary structures in session directory
sessionDir = dir;

sessionDirNames = {sessionDir.name};

whiskDataStrucName = findLatestFilename('whiskDataStruc');
load(whiskDataStrucName);

sessionName = whiskDataStrucName(1:strfind(whiskDataStrucName, 'whisk')-2);

dbsName = findLatestFilename('dendriteBehavStruc');
load(dbsName);

segName = findLatestFilename('_seg_');
load(segName);

goodSegName = findLatestFilename('_goodSeg_');
load(goodSegName);


%binFilename = sessionDir(find(cellfun(@length, strfind(sessionDirNames, '.bin')))).name;
binFilename = findLatestFilename('.bin');
x2 = binRead2pSingleName(binFilename);

filename = sessionName;%dendriteBehavStruc.filename;

unitWhiskXcorrStruc.sessionName = sessionName;
unitWhiskXcorrStruc.date = date;
unitWhiskXcorrStruc.dbsName = dbsName;
unitWhiskXcorrStruc.whiskDataStrucName = whiskDataStrucName;

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
%tMs = frameTrig(1):frameTrig(end);  % time in ms of 2p imaging
tMs = frameTrig(1):10:frameTrig(end);

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


for unit = 1:length(goodSeg)
    
    segCa = segStruc.C(:,goodSeg(unit)); % extract unit Ca
    
    % interp frameAvgDf to ms
    ca2 = interp1(frameTrig, segCa, tMs);
    ca2(isnan(ca2)) = nanmean(ca2);
    ca3 = (ca2-mean(ca2))/std(ca2);
    
    disp(['Calculating calcium/whisking xcorr for seg#' num2str(goodSeg(unit))]);
    
    %% XCORR for these epochs
    if forEpochs
        
        % now calculate xcorr for all these epochs
        % NOTE 160409: now I'm calculating xcorr for all stim and ITI epochs and
        % then selecting out particular stim/iti types for averages
        
        % 1.) all ITIs
        
        tic;
        %allItiXcorr = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, itiBegTimes, itiEndTimes);
        allItiXcorr = whiskCaEpochXCorrSingle(ca3, wd3, tMs, itiBegTimes, itiEndTimes);
        allItiXcorr = allItiXcorr';
        
        allItiXcorrUnits(:,:,unit) = allItiXcorr;
        
        % 2.) all stim/catch epochs
        %allStimXcorr = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, stimEpBegTimes, stimEpEndTimes);
        allStimXcorr = whiskCaEpochXCorrSingle(ca3, wd3, tMs, stimEpBegTimes, stimEpEndTimes);
        allStimXcorr = allStimXcorr';
        
        allStimXcorrUnits(:,:,unit) = allStimXcorr;
        
        toc;
        
        
        %% Select xcorr for trials of particular types
        
        rewStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
        rewStimInd =  rewStimInd(rewStimInd <= size(allStimXcorr,2));
        unrewStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
        unrewStimInd =  unrewStimInd(unrewStimInd <= size(allStimXcorr,2));
        
        rewStimXcorr = allStimXcorr(:, rewStimInd); %  <= size(allStimXcorr,1)), :);
        unrewStimXcorr = allStimXcorr(:, unrewStimInd); %  <= size(allStimXcorr,1)), :);
        
        rewStimXcorrUnits(:,:,unit) =  rewStimXcorr;
        unrewStimXcorrUnits(:,:,unit) =  unrewStimXcorr;
        
        correctRewStimInd = dendriteBehavStruc.eventStruc.correctRewStimInd;
        correctRewStimInd =  correctRewStimInd(correctRewStimInd <= size(allStimXcorr,2));
        correctRewXcorr = allStimXcorr(:, correctRewStimInd); % <= size(allStimXcorr,1)), :);
        if isempty(correctRewXcorr)
            correctRewXcorr =  NaN(601, 1);
        end
        
        correctRewXcorrUnits(:,:,unit) =  correctRewXcorr;
        
        incorrectRewStimInd = dendriteBehavStruc.eventStruc.incorrectRewStimInd;
        incorrectRewStimInd =  incorrectRewStimInd(incorrectRewStimInd <= size(allStimXcorr,2));
        incorrectRewXcorr = allStimXcorr(:,incorrectRewStimInd); % <= size(allStimXcorr,1)), :);
        if isempty(incorrectRewXcorr)
            incorrectRewXcorr =   NaN(601, 1);
        end
        
        incorrectRewXcorrUnits(:,:,unit) = incorrectRewXcorr;
        
        correctUnrewStimInd = dendriteBehavStruc.eventStruc.correctUnrewStimInd;
        correctUnrewStimInd =  correctUnrewStimInd(correctUnrewStimInd <= size(allStimXcorr,2));
        correctUnrewXcorr = allStimXcorr(:,correctUnrewStimInd); % <= size(allStimXcorr,1)), :);
        if isempty(correctUnrewXcorr)
            correctUnrewXcorr =  NaN(601, 1);
        end
        
        correctUnrewXcorrUnits(:,:,unit) = correctUnrewXcorr;
        
        incorrectUnrewStimInd = dendriteBehavStruc.eventStruc.incorrectUnrewStimInd;
        incorrectUnrewStimInd =  incorrectUnrewStimInd(incorrectUnrewStimInd <= size(allStimXcorr,2));
        incorrectUnrewXcorr = allStimXcorr(:,incorrectUnrewStimInd); % <= size(allStimXcorr,1)), :);
        if isempty(incorrectUnrewXcorr)
            incorrectUnrewXcorr =  NaN(601,1);
        end
        
        incorrectUnrewXcorrUnits(:,:,unit) = incorrectUnrewXcorr;
        
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
            randRewItiXcorr = allItiXcorr(:,randRewItiInd);
            normalItiXcorr = allItiXcorr(:,normalItiInd);
            randRewItiXcorrUnits(:,:,unit) = randRewItiXcorr;
            normalItiXcorrUnits(:,:,unit) = normalItiXcorr;
        catch
            disp('No randRew in this session');
            randRewItiXcorrUnits = NaN(601,1);
            normalItiXcorrUnits = allItiXcorr;
        end
        
        if itiEndTimes(end)-itiBegTimes(end) > 10000
            lastItiXcorrUnits(:,unit) = allItiXcorr(:, end);
        end
        
        %lastItiXcorrUnits(:,:,unit) = lastItiXcorr;
        
        try
            n=0;
            for numTrial = 1:length(itiBegTimes)
                if length(itiEndTimes(numTrial)-itiBegTimes(numTrial)) > 10000
                    n=n+1;
                    longItiXcorr(:,n) = allItiXcorr(:,numTrial);
                end
            end
            
            longItiXcorrUnits(:,:,unit) = longItiXcorr;
            
        catch
            disp('No long (>10s) ITIs');
            longItiXcorrUnits = NaN(601,1);
        end
        
    end % end IF forEpochs
    
    %% Full session Xcorr
    tic;
    fullSessionXcorr = xcorr(ca3, wd3', 300, 'coeff');
    toc;
    fullSessionXcorrUnits(:,unit) = fullSessionXcorr';
    %unitWhiskXcorrStruc.fullSessionXcorr = fullSessionXcorr;
    
end  % end FOR all units in goodSeg


%% build output structure
unitWhiskXcorrStruc.fullSessionXcorrUnits = fullSessionXcorrUnits;

if forEpochs
    unitWhiskXcorrStruc.allStimXcorrUnits = allStimXcorrUnits;
    unitWhiskXcorrStruc.allItiXcorrUnits = allItiXcorrUnits;
    
    unitWhiskXcorrStruc.rewStimXcorrUnits = rewStimXcorrUnits;
    unitWhiskXcorrStruc.unrewStimXcorrUnits = unrewStimXcorrUnits;
    
    unitWhiskXcorrStruc.correctRewXcorrUnits = correctRewXcorrUnits;
    unitWhiskXcorrStruc.incorrectRewXcorrUnits = incorrectRewXcorrUnits;
    
    unitWhiskXcorrStruc.correctUnrewXcorrUnits = correctUnrewXcorrUnits;
    unitWhiskXcorrStruc.incorrectUnrewXcorrUnits = incorrectUnrewXcorrUnits;
    
    unitWhiskXcorrStruc.lastItiXcorrUnits = lastItiXcorrUnits;
    unitWhiskXcorrStruc.longItiXcorrUnits = longItiXcorrUnits;
end

%% Plotting

if toPlot
    figure;
    plot(-300:300, fullSessionXcorrUnits); %, 'Color', [1 0.5 0.2]);
    xlim([-300 300]);
    title([filename ' XCORR unit Ca2+ vs whiskerAngle ' date]);
end