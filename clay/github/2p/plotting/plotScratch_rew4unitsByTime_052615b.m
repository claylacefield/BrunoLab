

%%


% % find units with significant rew4 pVals
% pvalThresh = 0.05;
% sigUnitInd = find(mouseUnitEpochSortStruc.unitRandRewPvalArr < pvalThresh);
% 
% % to find S+/- units
% rateRatio = mouseUnitEpochSortStruc.rewEpRate(:,2)./mouseUnitEpochSortStruc.rewEpRate(:,1);
% 
% % load in average rewStimInd Ca for all units
% rewStimCa = mouseUnitEpochSortStruc.rewStimCaAvg;
% 
% % then select rew4 units out
% rew4rewStimCa = rewStimCa(:,sigUnitInd);


%%

avCa = mouseUnitEpochSortStruc.rewStimCaAvg;

% for each unit processed in mouseUnitEpochSortStruc
for numSeg = 1:size(avCa,2)
    
    ca = avCa(:,numSeg);  % load in caAvg for this unit
    
    ca = runmean(ca,2);
    
    ca = (ca-mean(ca))/std(ca); % convert Ca to Zscores
    
    %ca = runmean(ca,2);
    
    avCa2(:,numSeg) = interp1(-2:0.25:6,ca, -2:0.001:6); % interp to smooth
end

rew4rewStimCa2 = avCa2(:,sigUnitInd);
notSigUnitInd = setxor(1:size(avCa2,2),sigUnitInd);
notRew4Ca = avCa2(:,notSigUnitInd);

[pkValArr4, pkIndArr4] = max(rew4rewStimCa2(1:5000,:),[],1);
[pkValArr, pkIndArr] = max(notRew4Ca(1:5000,:),[],1);
[sortedInd4, origInd4] = sort(pkIndArr4);
[sortedInd, origInd] = sort(pkIndArr);
avCaSort4 = rew4rewStimCa2(:,origInd4);
avCaSort = notRew4Ca(:,origInd);

figure; colormap(jet);
subplot(1,2,1);
imagesc(avCaSort4'); %hold on; line([2000 2000], [0 size(avCaSort4,2)], 'Color', [0.1 0.2 0.2]);
subplot(1,2,2);
imagesc(avCaSort');

%%


[pkValArr, pkIndArr] = max(avCa2(1:5000,:),[],1);
[sortedInd, origInd] = sort(pkIndArr);
avCaSortAll = avCa2(:,origInd);

figure;  colormap(jet);
imagesc(avCaSortAll');

%%


% sem = std(rew4rewStimCa')/sqrt(size(rew4rewStimCa,2));
% %errorbar(-2:0.25:6, mean(segCa,2), sem);
% plot(-2:0.25:6,segCa)
% 
% 
% figure;
% plot(mean(rew4rewStimCa2,2));


%%
% 
% d1 = designfilt('lowpassiir','FilterOrder',12, ...
%     'HalfPowerFrequency',0.15,'DesignMethod','butter');
% 
% 
% for numSeg = 1:size(avCaSort,2)
%     ca = avCaSort(:,numSeg);
%     avCaSort2(:,numSeg) = filtfilt(d1,ca);
% 
% end
% 


