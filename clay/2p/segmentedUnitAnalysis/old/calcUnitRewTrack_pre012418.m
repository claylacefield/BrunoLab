function [unitRewTrackStruc] = calcUnitRewTrack(segStruc, goodSeg)

%%  calc unit rewDelay stats (from unitRew4DelHitMissStats2.m)

try
    
    % load in rewDelayCa for goodSegs
    try
        rewDelay1TimeCa = squeeze(mean(segStruc.rewDelay1TimeCa(:,goodSeg,:),3));
        rewDelay2TimeCa = squeeze(mean(segStruc.rewDelay2TimeCa(:,goodSeg,:),3));
        rewDelay3TimeCa = squeeze(mean(segStruc.rewDelay3TimeCa(:,goodSeg,:),3));
    catch
        disp('Missing one or more rewDelay fields');
    end
    
    % find peak ind (and vals) for all units
    
    
    if size(rewDelay1TimeCa,1) == 33
        for seg = 1:length(goodSeg)
            %totalNumSeg = totalNumSeg + 1;
            segDel1CaAvg = rewDelay1TimeCa(:,seg);
            [segDel1maxVal, segDel1maxInd] = max(segDel1CaAvg(13:19));
            segDel2CaAvg = rewDelay2TimeCa(:,seg);
            [segDel2maxVal, segDel2maxInd] = max(segDel2CaAvg(13:19));
            segDel3CaAvg = rewDelay3TimeCa(:,seg);
            [segDel3maxVal, segDel3maxInd] = max(segDel3CaAvg(13:19));
            
            segDelCell{seg} = [segDel1maxInd segDel2maxInd segDel3maxInd; segDel1maxVal segDel2maxVal segDel3maxVal];
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
    
catch
    disp('Prob calculating rewTracking');
end

%%

% rewEpRateCell = segStruc.rewEpRateCell(goodCellInds);
% rewEpRateMat = [];
% rewStimCa = {segStruc.rewStimCa{goodCellInds}};
% rewStimCaArr = [];
% for numSess = 1:length(goodCellInds);
%     rewEpRateMat = cat(1, rewEpRateMat, rewEpRateCell{numSess});
%     rewStimCaAvgSess = squeeze(mean(rewStimCa{numSess},3));
%     rewStimCaArr = [rewStimCaArr rewStimCaAvgSess];
% end
%
%
% %%
% unitRew4DelayStats.rewEpRateMat = rewEpRateMat;
%
% unitRew4DelayStats.unitRandRewPval = [segStruc.unitRandRewPvalCell{goodCellInds}];
% unitRew4DelayStats.rewStimCa = rewStimCaArr;








