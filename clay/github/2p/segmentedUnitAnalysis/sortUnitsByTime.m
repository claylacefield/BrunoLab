function [ca2] = sortUnitsByTime(segStruc, goodSeg, sortEvent, plotEvent, toNorm, toPlot)

% This function sorts all goodUnits for a session's segStruc based upon
% their average rewStim calcium during prestim and stim period and plots as
% a normalized heatmap

if sortEvent == 0
    sortEvent = 'rewStimStimIndCa';
    plotEvent = sortEvent;
end

avCa = mean(segStruc.(sortEvent), 3);

plotCa = mean(segStruc.(plotEvent),3);

for numSeg = 1:length(goodSeg)
    
    ca = avCa(:,goodSeg(numSeg));
    [pkVal, pkInd] = max(ca(1:24));
    pkValArr(numSeg) = pkVal;
    pkIndArr(numSeg) = pkInd;
    
end

[sortedInd, origInd] = sort(pkIndArr);

for numSeg = 1:length(goodSeg)
    
    ca = plotCa(:,goodSeg(origInd(numSeg)));
    if toNorm == 1
    ca = (ca-mean(ca))/std(ca);
    end
    
    ca2(numSeg,:) = interp1(-2:0.25:6,ca, -2:0.001:6);
end

if toPlot
figure; 
imagesc(ca2);
title(segStruc.filename);
end
