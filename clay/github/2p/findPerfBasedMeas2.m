function [eventStruc] = findPerfBasedMeas2(eventStruc, binMin)

% broke this out of detect2pEventsNameNew on 021917

stimTrig = eventStruc.stimTrigTime;
rewTime1 = eventStruc.rewTime1;
punTime1 = eventStruc.punTime1;
correctRespStruc = eventStruc.correctRespStruc;

try

maxStimTrig = max(stimTrig);
%binMin = 3;     % size of time bin for performance measure, in min
binSize = binMin*60*1000;  % size of bins to computer avg performance, in ms
corrRespArr = correctRespStruc.corrRespArr;

% find performance per bin
for perfBins = 1:(ceil(maxStimTrig/binSize))   % for all bins
    stimIndBin = find((stimTrig >= (binSize*(perfBins-1))) & (stimTrig <= (binSize*perfBins))); % find stim triggers in this bin
    corrRespBin = corrRespArr(stimIndBin);  % find the corresponding responses for those trials (correct = 1)
    percCorrBin(perfBins) = sum(corrRespBin)/length(corrRespBin); % and calculate the percent correct for this bin
end

% this part isolates bins with good/med/bad performance
goodPerfPerc = 0.7; % = 0.75; % changed 072214
badPerfPerc = 0.6; % = 0.65;

% find bins with good/bad performance
goodPerfBins = find(percCorrBin >= goodPerfPerc);
medPerfBins = find(percCorrBin > badPerfPerc & percCorrBin < goodPerfPerc);
badPerfBins = find(percCorrBin <= badPerfPerc);

goodRew1Times = [];
medRew1Times = [];
badRew1Times = [];
goodPun1Times = [];
medPun1Times = [];
badPun1Times = [];

% and then find the rew1 times during those good/bad timebins
for goodBin = 1:length(goodPerfBins)
    goodRew1Times = [goodRew1Times; rewTime1(rewTime1 >= (goodPerfBins(goodBin)-1)*binSize & rewTime1 < goodPerfBins(goodBin)*binSize)];
    goodPun1Times = [goodPun1Times; punTime1(punTime1 >= (goodPerfBins(goodBin)-1)*binSize & punTime1 < goodPerfBins(goodBin)*binSize)];
    
end

for medBin = 1:length(medPerfBins)
    medRew1Times = [medRew1Times; rewTime1(rewTime1 >= (medPerfBins(medBin)-1)*binSize & rewTime1 < medPerfBins(medBin)*binSize)];
    medPun1Times = [medPun1Times; punTime1(punTime1 >= (medPerfBins(medBin)-1)*binSize & punTime1 < medPerfBins(medBin)*binSize)];
end

for badBin = 1:length(badPerfBins)
    badRew1Times = [badRew1Times; rewTime1(rewTime1 >= (badPerfBins(badBin)-1)*binSize & rewTime1 < badPerfBins(badBin)*binSize)];
    badPun1Times = [badPun1Times; punTime1(punTime1 >= (badPerfBins(badBin)-1)*binSize & punTime1 < badPerfBins(badBin)*binSize)];
end


eventStruc.goodRew1Times = goodRew1Times;
eventStruc.medRew1Times = medRew1Times;
eventStruc.badRew1Times = badRew1Times;
eventStruc.goodPun1Times = goodPun1Times;
eventStruc.medPun1Times = medPun1Times;
eventStruc.badPun1Times = badPun1Times;
catch
disp('Cannot compute performance-based measures');    
end