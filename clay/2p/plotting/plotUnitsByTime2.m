function plotUnitsByTime2(mouseUnitEpochSortStruc)

avCa = mouseUnitEpochSortStruc.rewStimCaAvg;

for numSeg = 1:size(avCa,2)
    
    ca = avCa(:,numSeg);
    [pkVal, pkInd] = max(ca(1:24));
    pkValArr(numSeg) = pkVal;
    pkIndArr(numSeg) = pkInd;
    
end

[sortedInd, origInd] = sort(pkIndArr);

for numSeg = 1:size(avCa,2)
    
    ca = avCa(:,origInd(numSeg));
    ca = (ca-mean(ca))/std(ca);
    ca2(numSeg,:) = interp1(-2:0.25:6,ca, -2:0.001:6);
end

colormap(jet);
figure; imagesc(ca2);

figure; 
hold on; 
for i = 1:size(avCa,2)
    plot(4*ca2(i,:)-i);
end