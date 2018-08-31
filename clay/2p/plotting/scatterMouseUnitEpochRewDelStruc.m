function scatterMouseUnitEpochRewDelStruc(mouseUnitEpochSortStruc)

pvalThresh = 0.05;
sigRew4UnitInd = find(mouseUnitEpochSortStruc.unitRandRewPval <= pvalThresh);
sigUnitInd = find(mouseUnitEpochSortStruc.segDiffInd == 0);

%rateRatio = mouseUnitEpochSortStruc.rewEpRate(:,2)./mouseUnitEpochSortStruc.rewEpRate(:,1);

rewEpRate1 = squeeze(mouseUnitEpochSortStruc.rewEpRateMat(:,1,1));
%rewEpRate2 = mouseUnitEpochSortStruc.rewEpRateMat(:,2,1);
%rewEpRate2 = (squeeze(mouseUnitEpochSortStruc.rewEpRateMat(:,2,1))+squeeze(mouseUnitEpochSortStruc.rewEpRateMat(:,3,1)))/2;
rewEpRate2 = max([squeeze(mouseUnitEpochSortStruc.rewEpRateMat(:,2,1)) squeeze(mouseUnitEpochSortStruc.rewEpRateMat(:,3,1))],[],2);
rateRatio = rewEpRate2./rewEpRate1;

numSplus = sum(rateRatio>1);
numSminus = sum(rateRatio<1);

numSplusDel = sum(rateRatio(sigUnitInd)>1);
numSminusDel = sum(rateRatio(sigUnitInd)<1);

successes = [numSplusDel numSminusDel];
attempts = [numSplus, numSminus];
alternative = 2;
[pval] = CompareProportions(successes, attempts, alternative);

numSplusRrew = sum(rateRatio(sigRew4UnitInd)>1);
numSminusRrew = sum(rateRatio(sigRew4UnitInd)<1);

successes = [numSplusRrew numSminusRrew];
attempts = [numSplus, numSminus];
alternative = 2;
[pval2] = CompareProportions(successes, attempts, alternative);

%figure; 
%subplot(2,2,1);
line([0 0.1], [0 0.1], 'Color', 'r'); hold on; 
scatter(rewEpRate1, rewEpRate2);
scatter(rewEpRate1(sigUnitInd), rewEpRate2(sigUnitInd), 'g');
scatter(rewEpRate1(sigRew4UnitInd), rewEpRate2(sigRew4UnitInd), 'r');
title([ 'S+/- compar pVal= ' num2str(pval) ', ' num2str(numSplusDel) ...
    '/' num2str(numSplus) ' S+, ' num2str(numSminusDel) '/' ...
    num2str(numSminus) ' S-; ' 'S+/- compar pVal= ' num2str(pval2) ', ' num2str(numSplusRrew) ...
    '/' num2str(numSplus) ' S+, ' num2str(numSminusRrew) '/' ...
    num2str(numSminus) ' S-; ']);
xlabel('prestim ep1 rate');
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