
numSegCa = 0; outAllSegCa = {};
for i = 1:length(rewStimCa)
   sessAllSegCa = rewStimCa{i};
   for seg = 1:size(sessAllSegCa,2)
       numOkTrial = 0; ca = [];
       sessSegCa = squeeze(sessAllSegCa(:,seg,:));
       for evNum = 1:size(sessSegCa,2)
           segTrialCa = sessSegCa(:, evNum);
           if max(segTrialCa(3:30)) >= (mean(sessSegCa(:))+2*std(sessSegCa(:)))
               numOkTrial = numOkTrial + 1;
               ca(:,numOkTrial) = segTrialCa;
           end
       end
       %outAllSegCa{i,seg} = ca;
       numSegCa = numSegCa + 1;
       outAllSegCa{numSegCa} = ca;
   end
   %outRewCaCell{i} = outAllSegCa;
end


seg = 10;
%figure; plot(outAllSegCa{seg});
figure; plot(mean(outAllSegCa{seg},2));




for seg = 1:length(outAllSegCa)
    segCa(:,seg) = mean(outAllSegCa{seg},2);
end

% plot the adjusted calcium
figure; 
plot(segCa);

%% calculate proportion of rew4 units based upon new calcium meas
pval = mouseUnitEpochSortStruc.unitRandRewPvalArr;
rew4ind = find(pval <= 0.05);
ep1 = mean(segCa(2:10,:),1);
ep2 = mean(segCa(11:27,:),1);


figure; scatter(ep1, ep2);
hold on; line([0 0.5], [0 0.5]);
scatter(ep1(rew4ind), ep2(rew4ind), 'r');

ratio = ep2./ep1;

posInd = find(ratio > 1);
negInd = find(ratio < 1);
posP = pval(posInd);
negP = pval(negInd);

pos4 = find(posP < 0.05);
neg4 = find(negP < 0.05);

pv = CompareProportions([length(neg4) length(pos4)], [length(negInd) length(posInd)],2);



