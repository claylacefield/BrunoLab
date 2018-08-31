

d1 = designfilt('lowpassiir','FilterOrder',12, ...
    'HalfPowerFrequency',0.15,'DesignMethod','butter');


for numSeg = 1:size(avCaSort,2)
    ca = avCaSort(:,numSeg);
    avCaSort2(:,numSeg) = filtfilt(d1,ca);

end



%%


% find units with significant rew4 pVals
pvalThresh = 0.01;
sigUnitInd = find(mouseUnitEpochSortStruc.unitRandRewPvalArr < pvalThresh);

% to find S+/- units
rateRatio = mouseUnitEpochSortStruc.rewEpRate(:,2)./mouseUnitEpochSortStruc.rewEpRate(:,1);

% load in average rewStimInd Ca for all units
rewStimCa = mouseUnitEpochSortStruc.rewStimCaAvg;

% then select rew4 units out
rew4rewStimCa = rewStimCa(:,sigUnitInd);


%%

avCa = mouseUnitEpochSortStruc.rewStimCaAvg;

% for each unit processed in mouseUnitEpochSortStruc
for numSeg = 1:size(avCa,2)
    
    ca = avCa(:,numSeg);  % load in caAvg for this unit
    
    ca = (ca-mean(ca))/std(ca); % convert Ca to Zscores
    
    avCa2(:,numSeg) = interp1(-2:0.25:6,ca, -2:0.001:6); % interp to smooth
end

rew4rewStimCa2 = avCa2(:,sigUnitInd);
notSigUnitInd = setxor(1:size(avCa2,2),sigUnitInd);
notRew4Ca = avCa2(:,notSigUnitInd);

%%


sem = std(rew4rewStimCa')/sqrt(size(rew4rewStimCa,2));
    %errorbar(-2:0.25:6, mean(segCa,2), sem); 
    plot(-2:0.25:6,segCa)
    
    
    figure; 
    plot(mean(rew4rewStimCa2,2));
    