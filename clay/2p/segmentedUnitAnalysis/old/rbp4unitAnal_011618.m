function rbp4unitAnal_011618()


% Clay
% 011618

% This script should
% 1. load in sessions from rbp4unitEpochStruc (R103, R112 units used in
% paper Fig. 3)
% 2. run unitRandRewITIproportion to extract rew4 units (NOTE that indices
% are based upon goodSegs)
% 3. 

load('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R103R112_rbp4unitEpochStruc_121017a.mat');

for i = 1:length(rbp4unitEpochStruc)
    
    % go to the session folder
    cd(rbp4unitEpochStruc(i).sessionPath);  % go to session
    
    % load in necessary strucs
    load(findLatestFilename('_dendriteBehavStruc_'));
    load(findLatestFilename('_seg_'));
    load(findLatestFilename('_goodSeg_'));
    
    % but can take unitEpochStruc from input struc
    unitEpochStruc = rbp4unitEpochStruc(i).unitEpochStruc;
    % [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg);
    
    % from unitEpochSortItiPropMouse.m
    % for randRew units
    toPlot = 1;
    [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot);
    rew4unInd = unitItiPropStruc.rew4unInd; % goodSeg indices of units with rew4 pval<0.05
    prestimRate = unitEpochStruc.rewEpRate(rew4unInd,1);
    poststimRate = unitEpochStruc.rewEpRate(rew4unInd,2);
    
    
    
    % now need to integrate rewDelay stuff from unitRew4DelayCaMouse.m
    
    % from unitEpochSortItiPropMouse.m
      mouseUnitEpochSortStruc.rewEpRate = [mouseUnitEpochSortStruc.rewEpRate; unitEpochStruc.rewEpRate];
                            mouseUnitEpochSortStruc.rewEpRate2 = [mouseUnitEpochSortStruc.rewEpRate2; unitEpochStruc.rewEpRate2];
                            mouseUnitEpochSortStruc.rewEpRateAdj = [mouseUnitEpochSortStruc.rewEpRateAdj; unitEpochStruc.rewEpRateAdj];
                            mouseUnitEpochSortStruc.rewEpRate2Adj = [mouseUnitEpochSortStruc.rewEpRate2Adj; unitEpochStruc.rewEpRate2Adj];
                            
                            
                             % from randRewUnitsBySessionR103R112_092415a.m
rewEpRateMat = unitRew4DelayStats.rewEpRateMat(:,:,1)*4;
unitRandRewPval = unitRew4DelayStats.unitRandRewPval;
segDiffInd = unitRew4DelayStats.segDiffInd;
rewStimCa = unitRew4DelayStats.rewStimCa;

randRewUnitInd = find(unitRandRewPval <= 0.05);
rewTrackUnitInd = find(segDiffInd <= 1);
bothRewUnitInd = intersect(randRewUnitInd, rewTrackUnitInd);


numSplusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))>1));
numSminusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))<1));
    
% from unitRew4DelayCaMouse.m
    try
        unitRew4DelayStruc.rewDelay1TimeCa{totalSessNum} = squeeze(segStruc.rewDelay1TimeCa(:,goodSeg,:)); % [unitRew4DelayStruc.rewStimCaAvg avCa(:,goodSeg)];
        unitRew4DelayStruc.rewDelay2TimeCa{totalSessNum} = squeeze(segStruc.rewDelay2TimeCa(:,goodSeg,:));
        unitRew4DelayStruc.rewDelay3TimeCa{totalSessNum} = squeeze(segStruc.rewDelay3TimeCa(:,goodSeg,:));
    catch
        disp('Problem processing rewDelay');
    end
    
    try
        eventType = 'isoLickTime';
        [hitFAeventCa, missCReventCa] = unitHitFAmissCRca(dendriteBehavStruc, segStruc, eventType);
        unitRew4DelayStruc.hitFAeventCa{totalSessNum} = squeeze(hitFAeventCa(:,goodSeg,:));
        unitRew4DelayStruc.missCReventCa{totalSessNum} = squeeze(missCReventCa(:,goodSeg,:));
    catch
        disp('Could not calculate hitFAmissCR for this session');
    end
    
end
