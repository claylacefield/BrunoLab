function plotGoodSegEpochScatter(segStruc, goodSeg, event, newFig)




eventPks = segStruc.(event);

eventPks = eventPks(:,goodSeg);

prestimPks = eventPks(1:8, :);
poststimPks = eventPks(9:16, :);

if newFig
figure; 
title(segStruc.filename);
end

scatter(mean(prestimPks, 1), mean(poststimPks, 1));
line([0 10], [0 10], 'Color', 'r');




