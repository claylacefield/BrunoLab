


whCaXgroupCompil.randRewITIs = [whCaXgroupCompil.randRewITIs nanmean(whCaXCorrGroupStruc.randRewITIs,2)];
whCaXgroupCompil.allITIs = [whCaXgroupCompil.allITIs nanmean(whCaXCorrGroupStruc.allITIs,2)];
whCaXgroupCompil.stimTrials = [whCaXgroupCompil.stimTrials nanmean(whCaXCorrGroupStruc.stimTrials,2)];
whCaXgroupCompil.catchTrials = [whCaXgroupCompil.catchTrials nanmean(whCaXCorrGroupStruc.catchTrials,2)];
whCaXgroupCompil.fullSession = [whCaXgroupCompil.fullSession nanmean(whCaXCorrGroupStruc.fullSession,2)];


figure; hold on;
plot(nanmean(whCaXgroupCompil.allITIs, 2), 'm');
plot(nanmean(whCaXgroupCompil.randRewITIs, 2),'b');
plot(nanmean(whCaXgroupCompil.stimTrials, 2), 'g');
plot(nanmean(whCaXgroupCompil.catchTrials, 2), 'r');
plot(nanmean(whCaXgroupCompil.fullSession, 2), 'c');
legend('allITIs', 'randRewITIs', 'stimTrials', 'catchTrials', 'fullSession');