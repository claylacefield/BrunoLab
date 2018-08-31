function plotUnitsByTime(segStruc, goodSeg)

avCa = mean(segStruc.rewStimStimIndCa, 3);

for numSeg = 1:length(goodSeg)
    
    ca = avCa(:,goodSeg(numSeg));
    [pkVal, pkInd] = max(ca(1:24));
    pkValArr(numSeg) = pkVal;
    pkIndArr(numSeg) = pkInd;
    
end

[sortedInd, origInd] = sort(pkIndArr);

for numSeg = 1:length(goodSeg)
    
    ca = avCa(:,goodSeg(origInd(numSeg)));
    ca = (ca-mean(ca))/std(ca);
    ca2(numSeg,:) = interp1(-2:0.25:6,ca, -2:0.001:6);
end

colormap(jet); imagesc(ca2);

