function [segStruc] = compileSegPks(segStruc, fps)

C = segStruc.C;

roiPkArr = [];
roiPkIndCell= {};
roiPkAmp = {};
roiPkRate = [];

roiPkArr2 = [];
roiPkIndCell2 = {};
roiPkAmp2 = {};
roiPkRate2 = [];

for roiNum = 1:size(C,2)
    
    roiDf = C(:,roiNum);
    
    roiPks = zeros(size(C,1),1);
    roiPks2 = zeros(size(C,1),1);
    
    try
        % now make hist of Ca2+ pks
        
        roiPkInd1 = roiPkDetect1(roiDf);
        
        
        roiPkAmp{roiNum} = roiDf(roiPkInd1);     % amp of detected pks
        roiPks(roiPkInd1) = 1;
        roiPkArr(:,roiNum) = roiPks;
        roiPkIndCell{roiNum} = roiPkInd1;
        roiPkRate(roiNum) = length(roiPkInd1)/length(roiDf);
        
        
        % 082614: now using second method
        % for ca peaks
        
        roiPkInd2 = roiPkDetect2(roiDf, fps);   % indices of Ca2+ pks
        
        
        roiPkAmp2{roiNum} = roiDf(roiPkInd2);     % amp of detected pks
        roiPks2(roiPkInd2) = 1;
        roiPkArr2(:,roiNum) = roiPks2;
        roiPkIndCell2{roiNum} = roiPkInd2;
        roiPkRate2(roiNum) = length(roiPkInd2)/length(roiDf);
        
    catch   % must try/catch for segments that are 0 (not sure why)
        roiPkAmp{roiNum} = [];
        roiPkArr(:,roiNum) = roiPks;
        roiPkIndCell{roiNum} = [];
        roiPkRate(roiNum) = 0;
        
        roiPkAmp2{roiNum} = [];
        roiPkArr2(:,roiNum) = roiPks2;
        roiPkIndCell2{roiNum} = [];
        roiPkRate2(roiNum) = 0;
    end
    
    clear roiPkInd roiPks;
    
end

segStruc.roiPkArr = roiPkArr;
segStruc.roiPkIndCell = roiPkIndCell;
segStruc.roiPkAmp = roiPkAmp;
segStruc.roiPkRate = roiPkRate;

segStruc.roiPkArr2 = roiPkArr2;
segStruc.roiPkIndCell2 = roiPkIndCell2;
segStruc.roiPkAmp2 = roiPkAmp2;
segStruc.roiPkRate2 = roiPkRate2;