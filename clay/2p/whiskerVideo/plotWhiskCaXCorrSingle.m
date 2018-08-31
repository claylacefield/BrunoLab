function plotWhiskCaXCorrSingle(whiskCaXCorrStruc)



figure; hold on;
plot(nanmean(whiskCaXCorrStruc.allItiXcorr, 1), 'm');
%plot(nanmean(whiskCaXCorrStruc.randRewITIs, 2),'b');
plot(nanmean(whiskCaXCorrStruc.rewStimXcorr, 1), 'g');
plot(nanmean(whiskCaXCorrStruc.unrewStimXcorr, 1), 'r');
plot(nanmean(whiskCaXCorrStruc.fullSessionXcorr, 1), 'c');
legend('allITIs', 'stimTrials', 'catchTrials', 'fullSession');


% figure; hold on;
% plot(whiskCaXCorrStruc.allItiXcorr', 'm');
% %plot(nanmean(whiskCaXCorrStruc.randRewITIs, 2),'b');
% plot(whiskCaXCorrStruc.rewStimXcorr', 'g');
% plot(whiskCaXCorrStruc.unrewStimXcorr', 'r');
% plot(whiskCaXCorrStruc.fullSessionXcorr, 'c');
% legend('allITIs', 'stimTrials', 'catchTrials', 'fullSession');