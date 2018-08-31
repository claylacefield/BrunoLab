function [segDiffInd, segDelSlope, segHitMissDiff] = unitRewDelHitMissStats(unitRewDelayStruc)

%% compile the fields from the two unitRewDelayStrucs
fieldNames = fieldnames(unitRewDelayStruc);
% 
% for field = 1:length(fieldNames)
%     unitRewDelayStruc.(fieldNames{field}) = [unitRewDelayStruc1.(fieldNames{field}) unitRewDelayStruc2.(fieldNames{field})];
% end
% 

%% make binary array of calcium fields with all data types
goodCellField = [];
goodCells = ones(1,length(unitRewDelayStruc.(fieldNames{5}))); % numCaField = 0;
for field = 1:length(fieldNames)
    
    if ~isempty(strfind(fieldNames{field}, 'Ca')) && isempty(strfind(fieldNames{field}, 'CaAvg'))
        %numCaField = numCaField + 1;
        fieldCell = unitRewDelayStruc.(fieldNames{field});
        
        for numSess = 1:length(fieldCell)
            if ~isempty(fieldCell{numSess})
                goodCellField(:,numSess) = 1;
            else
                goodCellField(:,numSess) = 0;
            end
        end 
        goodCells = goodCells.*goodCellField; 
    end
end
% this gives an array with ones for sessions with all relevant fields

% this converts to indices
goodCellInds = find(goodCells == 1);


%%  calc unit rewDelay stats

% load in rewDelayCa
rewDelay1TimeCa = unitRewDelayStruc.rewDelay1TimeCa;
rewDelay2TimeCa = unitRewDelayStruc.rewDelay2TimeCa;
rewDelay3TimeCa = unitRewDelayStruc.rewDelay3TimeCa;

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


%% calculate the hitFAmissCR stats

% load in hitFAmissCR data
hitFAeventCa = unitRewDelayStruc.hitFAeventCa;
missCReventCa = unitRewDelayStruc.missCReventCa;

% find peak ind (and vals) for all units
totalNumSeg = 0;
for sess = 1:length(goodCellInds)
    hitFAeventSess = hitFAeventCa{goodCellInds(sess)};
    missCReventSess = missCReventCa{goodCellInds(sess)};
    
    if size(hitFAeventSess,1) == 33
        for seg = 1:size(hitFAeventSess,2)
            totalNumSeg = totalNumSeg + 1;
            hitFAeventCaAvg = squeeze(mean(hitFAeventSess(:,seg,:),3));
            [hitFAmaxVal, hitFAmaxInd] = max(hitFAeventCaAvg(9:15));
            missCReventCaAvg = squeeze(mean(missCReventSess(:,seg,:),3));
            [missCRmaxVal, missCRmaxInd] = max(missCReventCaAvg(9:15));

            segHitMissCell{totalNumSeg} = [hitFAmaxInd missCRmaxInd; hitFAmaxVal missCRmaxVal];  
        end
    end
end

% now for each unit find the missCR-hitFA peak vals
for seg = 1:length(segHitMissCell)
    
    % load in peak data for this unit
    segMaxArr = segHitMissCell{seg};
    
    % calc hitFA vs missCR peak values
    segHitMissDiff(seg) = segMaxArr(2,2)-segMaxArr(2,1);
    
end


