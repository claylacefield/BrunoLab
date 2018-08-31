function scatterMouseUnitEpochSortStruc(mouseUnitEpochSortStruc)

pvalThresh = 0.05;
sigUnitInd = find(mouseUnitEpochSortStruc.unitRandRewPvalArr < pvalThresh);

%rateRatio = mouseUnitEpochSortStruc.rewEpRate(:,2)./mouseUnitEpochSortStruc.rewEpRate(:,1);

rateRatio = (mouseUnitEpochSortStruc.rewEpRate(:,2)+mouseUnitEpochSortStruc.rewEpRate(:,3))/2./mouseUnitEpochSortStruc.rewEpRate(:,1);

numSplus = sum(rateRatio>1);
numSminus = sum(rateRatio<1);

numSplusRrew = sum(rateRatio(sigUnitInd)>1);
numSminusRrew = sum(rateRatio(sigUnitInd)<1);

successes = [numSplusRrew numSminusRrew];
attempts = [numSplus, numSminus];
alternative = 2;
[pval] = CompareProportions(successes, attempts, alternative);

figure; 
%subplot(2,2,1);
line([0 0.1], [0 0.1], 'Color', 'r'); hold on; 
scatter(mouseUnitEpochSortStruc.rewEpRate(:,1), mouseUnitEpochSortStruc.rewEpRate(:,2));
scatter(mouseUnitEpochSortStruc.rewEpRate(sigUnitInd,1), mouseUnitEpochSortStruc.rewEpRate(sigUnitInd,2), 'r');
title([ 'pvalThresh= ' num2str(pvalThresh) ', S+/- compar pVal= ' num2str(pval)]);
hold off;

% subplot(2,2,2);
% line([0 0.1], [0 0.1], 'Color', 'r'); hold on; 
% scatter(mouseUnitEpochSortStruc.rewEpRate2(:,1), mouseUnitEpochSortStruc.rewEpRate2(:,2));
% scatter(mouseUnitEpochSortStruc.rewEpRate2(sigUnitInd,1), mouseUnitEpochSortStruc.rewEpRate2(sigUnitInd,2), 'r');
% hold off;
% 
% subplot(2,2,3);
% line([0 0.1], [0 0.1], 'Color', 'r'); hold on; 
% scatter(mouseUnitEpochSortStruc.rewEpRateAdj(:,1), mouseUnitEpochSortStruc.rewEpRateAdj(:,2));
% scatter(mouseUnitEpochSortStruc.rewEpRateAdj(sigUnitInd,1), mouseUnitEpochSortStruc.rewEpRateAdj(sigUnitInd,2), 'r');
% hold off;
% 
% subplot(2,2,4);
% line([0 0.1], [0 0.1], 'Color', 'r'); hold on; 
% scatter(mouseUnitEpochSortStruc.rewEpRate2Adj(:,1), mouseUnitEpochSortStruc.rewEpRate2Adj(:,2));
% scatter(mouseUnitEpochSortStruc.rewEpRate2Adj(sigUnitInd,1), mouseUnitEpochSortStruc.rewEpRate2Adj(sigUnitInd,2), 'r');
% hold off;