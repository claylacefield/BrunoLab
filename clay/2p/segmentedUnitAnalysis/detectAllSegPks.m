function [segStruc] = detectAllSegPks(segStruc, fps)

C = segStruc.C;

roiPkArr = [];
roiPkIndCell= {};
roiPkAmpCell = {};
roiPkRate = [];

roiPkArr2 = [];
roiPkIndCell2 = {};
roiPkAmpCell2 = {};
roiPkRate2 = [];

for roiNum = 1:size(C,2)
    
    roiDf = C(:,roiNum);
    
    roiPks = zeros(size(C,1),1);
    roiPks2 = zeros(size(C,1),1);
    
    try
        % now make hist of Ca2+ pks
        
        roiPkInd1 = roiPkDetect1(roiDf, fps);
        
        
        roiPkAmpCell{roiNum} = roiDf(roiPkInd1);     % amp of detected pks
        roiPks(roiPkInd1) = 1;  % binary array with 1s at roiPks
        roiPkArr(:,roiNum) = roiPks;
        roiPkIndCell{roiNum} = roiPkInd1;
        roiPkRate(roiNum) = length(roiPkInd1)/length(roiDf);
        
        
        % 082614: now using second method
        % for ca peaks
        
        roiPkInd2 = roiPkDetect2(roiDf, fps);   % indices of Ca2+ pks
        
        roiPkAmpCell2{roiNum} = roiDf(roiPkInd2);     % amp of detected pks
        roiPks2(roiPkInd2) = 1;
        roiPkArr2(:,roiNum) = roiPks2;
        roiPkIndCell2{roiNum} = roiPkInd2;
        roiPkRate2(roiNum) = length(roiPkInd2)/length(roiDf);
        
    catch   % must try/catch for segments that are 0 (not sure why)
        roiPkAmpCell{roiNum} = [];
        roiPkArr(:,roiNum) = roiPks;
        roiPkIndCell{roiNum} = [];
        roiPkRate(roiNum) = 0;
        
        roiPkAmpCell2{roiNum} = [];
        roiPkArr2(:,roiNum) = roiPks2;
        roiPkIndCell2{roiNum} = [];
        roiPkRate2(roiNum) = 0;
    end
    
    clear roiPkInd roiPks;
    
end

segStruc.roiPkArr = roiPkArr;
segStruc.roiPkIndCell = roiPkIndCell;
segStruc.roiPkAmpCell = roiPkAmpCell;
segStruc.roiPkRate = roiPkRate; % NOTE: rate is spikes/fr

segStruc.roiPkArr2 = roiPkArr2;
segStruc.roiPkIndCell2 = roiPkIndCell2;
segStruc.roiPkAmpCell2 = roiPkAmpCell2;
segStruc.roiPkRate2 = roiPkRate2;