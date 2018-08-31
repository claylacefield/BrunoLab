
function [binErrorRatesStruc] = binErrorRates(correctRespStruc, minBin, wPlot);

% clay 051711
% script to calculate binned error rates over the entire session

%minBin = 2;  % time base over which to calculate histograms (in minutes)
bin = minBin*60000; % bin size, in ms

for i= 1:length(correctRespStruc)
    stimTimeArr = correctRespStruc(i).stimTimeArr;  % load in variable of trial times for this day
    corrRespArr = correctRespStruc(i).corrRespArr;
    name = correctRespStruc(i).name;

    if length(stimTimeArr)>0    % check to make sure there are events in this file
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

        end

        binErrorRatesStruc(i).name = name;
        binErrorRatesStruc(i).binFracCorrect = binFracCorrect;  % save the binned performance for this day
        binErrorRatesStruc(i).stimTimeArr = stimTimeArr;  % and save parent variables from "correcRespStruc" into this struc just to have in same place
        binErrorRatesStruc(i).corrRespArr = corrRespArr;

        figure; bar(binFracCorrect);
        ylim([0 1]);
        title(name);
    end % end IF cond to make sure there are events in file

end
