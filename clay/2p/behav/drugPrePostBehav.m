function [perf] = drugPrePostBehav(sessionBasename)


%% [perf] = drugPrePostBehav(sessionBasename);

totalMin = 5;
preTime = totalMin*60000;

% find the time/s of drug administration

filename = [sessionBasename '.txt'];

correctRespStruc = correctResp2pSingleName(sessionBasename);

% now read in the TXT file as a cell array
fullCell= textread(filename,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% now find the index of the first actual data point
beginInd = (find(strcmp(fullCell, 'BEGIN DATA'))+1);

fullCell = fullCell(beginInd:end); % cut off header then pad end
fullCell = [fullCell; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'];

numDrug = 0;

for i = 1:length(fullCell)
    if strfind(fullCell{i}, 'DRUG')
        numDrug = numDrug + 1;
        drugInfTime(numDrug) = str2double(fullCell{i+1}); 
    end
end

drugInfTime1 = drugInfTime(1);

drugPreLim = drugInfTime1 - preTime;
drugPostLim = drugInfTime1 + preTime;  % just using same pre as post

% take 5min of behavior before and after first drug administration

stimTimeArr = correctRespStruc.stimTimeArr;
corrRespArr = correctRespStruc.corrRespArr;

% find indices for epochs before and after drug admin/infus
preDrugStimInd = find(stimTimeArr <= drugInfTime1 & stimTimeArr >= drugInfTime1-preTime);
postDrugStimInd = find(stimTimeArr >= drugInfTime1 & stimTimeArr <= drugInfTime1+preTime);

fracCorrPre = sum(corrRespArr(preDrugStimInd))/length(preDrugStimInd);
fracCorrPost = sum(corrRespArr(postDrugStimInd))/length(postDrugStimInd);

% now find binned performance

minBin = 1;  % time base over which to calculate histograms (in minutes)
bin = minBin*60000;

binFracCorrect = [];

% for epoch = 1:2    % check to make sure there are events in this file
%
stimTimes = stimTimeArr(preDrugStimInd);
corrResps = corrRespArr(preDrugStimInd);

firstTime = stimTimes(1);    % find last trial time
numBins = 5; % ceil(firstTime/bin);   % and compute total number of bins to use
%     lastTimeMinRound = ceil(lastTime/60000);  % find total number of minutes of session
%     numBins = minBin*ceil(lastTimeMinRound/minBin);
binFracCorrect = 0; % re-initialize array of binned performance for this day

for k=1:numBins  % for each timebin in trial
    
    % re-initialize vars for this bin
    binStimInds = 0; binCorrResp = 0;
    
    % compute fraction of correct responses for this timebin
    firstBinTime = (k-1)*bin + drugPreLim;
    lastBinTime = k*bin + drugPreLim;
    binStimInds = find(stimTimes > firstBinTime & stimTimes <= lastBinTime);    % find stim indices in this timebin
    binCorrResp = corrResps(binStimInds);    % find corresponding correct responses for these stimuli (1=correct, 0=incorrect)
    binFracCorrect(k,1) = sum(binCorrResp)/length(binCorrResp);    % calculate fraction of correct responses for this bin
    
end
% end

stimTimes = stimTimeArr(postDrugStimInd);
corrResps = corrRespArr(postDrugStimInd);

firstTime = stimTimes(1);    % find last trial time
numBins = 5; % ceil(firstTime/bin);   % and compute total number of bins to use
%     lastTimeMinRound = ceil(lastTime/60000);  % find total number of minutes of session
%     numBins = minBin*ceil(lastTimeMinRound/minBin);
%binFracCorrect = 0; % re-initialize array of binned performance for this day

for k=1:numBins  % for each timebin in trial
    
    % re-initialize vars for this bin
    binStimInds = 0; binCorrResp = 0;
    
    % compute fraction of correct responses for this timebin
    firstBinTime = (k-1)*bin + firstTime;
    lastBinTime = k*bin + firstTime;
    binStimInds = find(stimTimes > firstBinTime & stimTimes <= lastBinTime);    % find stim indices in this timebin
    binCorrResp = corrResps(binStimInds);    % find corresponding correct responses for these stimuli (1=correct, 0=incorrect)
    binFracCorrect(k,2) = sum(binCorrResp)/length(binCorrResp);    % calculate fraction of correct responses for this bin
    
end

perf = [binFracCorrect(:,1); binFracCorrect(:,2)];

figure; bar(perf);