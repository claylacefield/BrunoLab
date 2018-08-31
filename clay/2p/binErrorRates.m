function [binFracCorrect, varargout] = binErrorRates(correctRespStruc)

% clay 051711
% script to calculate binned error rates over the entire session

minBin = 1;  % time base over which to calculate histograms (in minutes)
bin = minBin*60000; % bin size, in ms


    stimTimeArr = correctRespStruc.stimTimeArr;  % load in variable of trial times for this day
    stimTypeArr = correctRespStruc.stimTypeArr;
    corrRespArr = correctRespStruc.corrRespArr;
    name = correctRespStruc.name;

    if length(stimTimeArr)>10    % check to make sure there are events in this file
        lastTime = stimTimeArr(end);    % find last trial time
        numBins = ceil(lastTime/bin);   % and compute total number of bins to use
        %     lastTimeMinRound = ceil(lastTime/60000);  % find total number of minutes of session
        %     numBins = minBin*ceil(lastTimeMinRound/minBin);
        binFracCorrect = 0; % re-initialize array of binned performance for this day

        for k=1:numBins  % for each timebin in trial

            % re-initialize vars for this bin
            binStimInds = 0; binCorrResp = 0;

            % compute fraction of correct responses for this timebin
            firstBinTime = (k-1)*bin;
            lastBinTime = k*bin;
            binStimInds = find(stimTimeArr > firstBinTime & stimTimeArr <= lastBinTime);    % find stim indices in this timebin
            binCorrResp = corrRespArr(binStimInds);    % find corresponding correct responses for these stimuli (1=correct, 0=incorrect)
            binFracCorrect(k) = sum(binCorrResp)/length(binCorrResp);    % calculate fraction of correct responses for this bin
            
            binStimType = stimTypeArr(binStimInds);
            binRewStimInds = find(binStimType == 1);  % stim type 1 = "bottom", really just rewarded (usu. bottom)
            binUnrewStimInds = find(binStimType == 2);
            binFracRew(k) = sum(binCorrResp(binRewStimInds))/length(binRewStimInds);
            binFracUnrew(k) = 1-sum(binCorrResp(binUnrewStimInds))/length(binUnrewStimInds);
            binDiscInd(k) = binFracRew(k) - binFracUnrew(k);
        end
        

    end % end IF cond to make sure there are events in file

    
    %nout = max(nargout,1)-1;
    if nargout == 2
        varargout{1} = binDiscInd;
    elseif nargout > 2
        varargout{1} = binDiscInd;
        varargout{2} = binFracRew;
        varargout{3} = binFracUnrew;
    end
