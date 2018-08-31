function [unitRew4DelayStruc2] = unitRewEpRate2cell(unitRew4DelayStruc)

numGoodSeg = unitRew4DelayStruc.numGoodSeg;

rewEpRate = unitRew4DelayStruc.rewEpRate;
rewEpRate2 = unitRew4DelayStruc.rewEpRate2;
rewEpRateAdj = unitRew4DelayStruc.rewEpRateAdj;
rewEpRate2Adj = unitRew4DelayStruc.rewEpRate2Adj;
unitRandRewPvalArr = unitRew4DelayStruc.unitRandRewPvalArr;

rewEpRateMat = cat(3, rewEpRate, rewEpRate2);
rewEpRateMat = cat(3, rewEpRateMat, rewEpRateAdj);
rewEpRateMat = cat(3, rewEpRateMat, rewEpRate2Adj);

totalSegNum = 0;
for numSess = 1:length(numGoodSeg)
    begInd = totalSegNum + 1;
    endInd = totalSegNum + numGoodSeg(numSess);
    rewEpRateCell{numSess} = rewEpRateMat(begInd:endInd, :,:);
    
    unitRandRewPvalCell{numSess} = unitRandRewPvalArr(begInd:endInd);
    
    totalSegNum = endInd;

end


unitRew4DelayStruc2 = unitRew4DelayStruc;
unitRew4DelayStruc2 = rmfield(unitRew4DelayStruc2, 'rewEpRate');
unitRew4DelayStruc2 = rmfield(unitRew4DelayStruc2, 'rewEpRate2');
unitRew4DelayStruc2 = rmfield(unitRew4DelayStruc2, 'rewEpRateAdj');
unitRew4DelayStruc2 = rmfield(unitRew4DelayStruc2, 'rewEpRate2Adj');
unitRew4DelayStruc2 = rmfield(unitRew4DelayStruc2, 'unitRandRewPvalArr');


% So the order for each epRate field is
% rewEpRate(#units,4epochs,1) = rewEpRate; % event rate for all 4 epochs, with x
% thresh
% rewEpRate(#units,4epochs,2) = rewEpRate2; % event rate for all 4 epochs,
% with x2 thresh
% rewEpRate(#units,4epochs,3) = rewEpRateAdj; % event rate for all 4 epochs, with x
% thresh, scaled by average event rate over whole session
% rewEpRate(#units,4epochs,4) = rewEpRate2Adj; % event rate for all 4 epochs,
% with x2 thresh, scaled by average event rate over whole session





