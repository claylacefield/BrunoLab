function [xc] = xcorrUnitPerf(dendriteBehavStruc, segStruc, goodSeg)

% this is a script to analyze the relationship between the unit calcium
% events and behavioral performance

% pseudocode
% 1. load in behavioral data from dendriteBehavStruc, unit data from
% segStruc, and goodSegs
% 2. calculate the performance over bins
% 3. for all goodSegs, bin the event rate (and amplitude)
% 4. Xcorr the events and performance

% Things to think about:
% - calculate the bins for ca and behav on same timebase
% - should I detect events again based upon the unit timecourse, or use the roiPk data
% - remember that I often had some period at end of recording with no
% events (to look at whisking alone) so I shouldn't include this in the
% tally (of course this time isn't that much so it might not matter)
% - should probably also calculate Xcorr based upon not just performance
% but also percentages of corr/incorr for each type of stim



unitCa = C(:,segNum);

%behavPerf = ;

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;

stimTrigTime = dendriteBehavStruc.eventStruc.stimTrigTime;

stimTypeArr = dendriteBehavStruc.eventStruc.correctRespStruc.stimTypeArr;
corrRespArr = dendriteBehavStruc.eventStruc.correctRespStruc.corrRespArr;

eventFields = {'rewStimStimInd' 'unrewStimStimInd'}; 

numSeg = length(goodSeg);

% bin the event time based upon the frame times
binSize = 60000;  % 30s bins

firstFrameTrig = frameTrig(1);
lastFrameTrig = frameTrig(end);

roiPkArr = segStruc.roiPkArr;

% for each bin, count the average number of events and average amplitude

for numBin = 1:ceil((lastFrameTrig-firstFrameTrig)/binSize)
    
    binStartTime = (numBin-1)*binSize;
    binEndTime = numBin*binSize-1;
    
    % calculate calcium event rate for this bin
    binFrInds = find(frameTrig>=binStartTime & frameTrig < binEndTime);
    
    for segNum = 1:numSeg
        seg = goodSeg(segNum);
        unitPkBin(numBin, segNum) = sum(roiPkArr(binFrInds,seg))/binSize*1000;  % calcium event rate/sec
    end
    
    % calculate performance for this bin
    binStimInds = find(stimTrigTime>=binStartTime & stimTrigTime < binEndTime); % find stimInds in this bin
    binStimType = stimTypeArr(binStimInds);  % see what types of stims they are
    binCorrResp = corrRespArr(binStimInds);  % see whether these responses are correct or incorrect
    
    rewInds = find(binStimType == 1);
    unrewInds = find(binStimType == 2);
    
    binRewPerf(numBin) = sum(binCorrResp(rewInds))/length(binCorrResp(rewInds));
    binUnrewPerf(numBin) = sum(binCorrResp(unrewInds))/length(binCorrResp(unrewInds));
    
    binPerf(numBin) = sum(binCorrResp)/length(binCorrResp);  % bin fraction of correct responses
    
end

for segNum = 1:numSeg
xc(:,segNum) = xcorr(unitPkBin(:,numSeg), binPerf, 'coeff');
end

% NOTE: this works in principle but I am still having problems because
% sometimes there are NaNs, which makes the xcorr barf. This is mostly at
% the end when there are no events, however this might occur at other
% points if an animal isn't triggering trials through lever press.


