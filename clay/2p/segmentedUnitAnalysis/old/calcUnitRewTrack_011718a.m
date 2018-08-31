function [unitRewTrackStruc] = calcUnitRewTrack(segStruc, goodSeg)

%%  calc unit rewDelay stats (from unitRew4DelHitMissStats2.m)

% load in rewDelayCa
rewDelay1TimeCa = segStruc.rewDelay1TimeCa;
rewDelay2TimeCa = segStruc.rewDelay2TimeCa;
rewDelay3TimeCa = segStruc.rewDelay3TimeCa;

% find peak ind (and vals) for all units
totalNumSeg = 0;
for sess = 1:length(goodCellInds)
    rewDel1Sess = rewDelay1TimeCa{goodCellInds(sess)};
    rewDel2Sess = rewDelay2TimeCa{goodCellInds(sess)};
    rewDel3Sess = rewDelay3TimeCa{goodCellInds(sess)};
    
    if size(rewDel1Sess,1) == 33
        for seg = 1:size(rewDel1Sess,2)
            totalNumSeg = totalNumSeg + 1;
            segDel1CaAvg = squeeze(mean(rewDel1Sess(:,seg,:),3));
            [segDel1maxVal, segDel1maxInd] = max(segDel1CaAvg(13:19));
            segDel2CaAvg = squeeze(mean(rewDel2Sess(:,seg,:),3));
            [segDel2maxVal, segDel2maxInd] = max(segDel2CaAvg(13:19));
            segDel3CaAvg = squeeze(mean(rewDel3Sess(:,seg,:),3));
            [segDel3maxVal, segDel3maxInd] = max(segDel3CaAvg(13:19));
            
            segDelCell{totalNumSeg} = [segDel1maxInd segDel2maxInd segDel3maxInd; segDel1maxVal segDel2maxVal segDel3maxVal];  
        end
    end
end

% now calculate stats based upon rewDelay peak inds
for seg = 1:length(segDelCell)
    
    % load in peak inds for this unit
    segMaxArr = segDelCell{seg};
    
    % method #1: sum of abs(diff) between delay times
    segDiffInd(seg) = abs(segMaxArr(1,1)-segMaxArr(1,2)) + abs(segMaxArr(1,2)-segMaxArr(1,3)) + abs(segMaxArr(1,1)-segMaxArr(1,3));
    
    % method #2: slope of peak ind for diff rewDelays
    count = 3;
    sumX = 6;
    sumY = segMaxArr(1,1) + segMaxArr(1,2) + segMaxArr(1,3);
    sumX2 = 14;
    sumXY = segMaxArr(1,1) + 2*segMaxArr(1,2) + 3*segMaxArr(1,3);
    xMean = sumX/count;
    yMean = sumY/count;
    slope = (sumXY - sumX*yMean)/(sumX2-sumX*xMean);
    segDelSlope(seg) = slope;
end



unitRewTrackStruc.segDiffInd = segDiffInd;
unitRewTrackStruc.segDelSlope = segDelSlope;

%%

rewEpRateCell = segStruc.rewEpRateCell(goodCellInds);
rewEpRateMat = []; 
rewStimCa = {segStruc.rewStimCa{goodCellInds}};
rewStimCaArr = [];
for numSess = 1:length(goodCellInds);
    rewEpRateMat = cat(1, rewEpRateMat, rewEpRateCell{numSess});
    rewStimCaAvgSess = squeeze(mean(rewStimCa{numSess},3));
    rewStimCaArr = [rewStimCaArr rewStimCaAvgSess];
end


%%
unitRew4DelayStats.rewEpRateMat = rewEpRateMat;

unitRew4DelayStats.unitRandRewPval = [segStruc.unitRandRewPvalCell{goodCellInds}];
unitRew4DelayStats.rewStimCa = rewStimCaArr;








