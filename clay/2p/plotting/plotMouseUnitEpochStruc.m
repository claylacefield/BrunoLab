function plotMouseUnitEpochStruc(mouseUnitEpochSortStruc)



rewEpRate = mouseUnitEpochSortStruc.rewEpRate;
rewEpRate2 = mouseUnitEpochSortStruc.rewEpRate2;
rewEpRateAdj = mouseUnitEpochSortStruc.rewEpRateAdj;
rewEpRate2Adj = mouseUnitEpochSortStruc.rewEpRate2Adj;

figure; 
subplot(2,2,1);
scatter(rewEpRate(:,1), rewEpRate(:,2));
subplot(2,2,2);
scatter(rewEpRate2(:,1), rewEpRate2(:,2));
subplot(2,2,3);
%title('rewEpRateAdj'); 
%figure;
scatter(rewEpRateAdj(:,1), rewEpRateAdj(:,2));
subplot(2,2,4);
scatter(rewEpRate2Adj(:,1), rewEpRate2Adj(:,2));

