function [rbp4unitEpochStruc] = rbp4unitAnal_011818b()


% Clay
% 011618

% This script should
% 1. load in sessions from rbp4unitEpochStruc (R103, R112 units used in
% paper Fig. 3)
% 2. run unitRandRewITIproportion to extract rew4 units (NOTE that indices
% are based upon goodSegs)
% 3.
% 4.
% 5. feed into scatterMouseUnitEpochRewDelStruc(mouseUnitEpochSortStruc).m;
%   - need mouseUnitEpochSortStruc.unitRandRewPval,
%   mouseUnitEpochSortStruc.segDiffInd, mouseUnitEpochSortStruc.rewEpRateMat
%   

load('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R103R112_rbp4unitEpochStruc_121017a.mat');

for i = 1:length(rbp4unitEpochStruc)
    
    % go to the session folder
    cd(rbp4unitEpochStruc(i).sessionPath);  % go to session
    disp(['Processing ' rbp4unitEpochStruc(i).sessionPath]);
    
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
    try
    [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot);
    %try
    rew4unInd = unitItiPropStruc.rew4unInd; % goodSeg indices of units with rew4 pval<0.05
    rbp4unitEpochStruc(i).rew4trackStruc.unitPropArr = unitItiPropStruc.unitPropArr;
    unitRandRewPval = unitItiPropStruc.unitRandRewPval;
    rbp4unitEpochStruc(i).rew4trackStruc.unitRandRewPval = unitRandRewPval;
    rbp4unitEpochStruc(i).rew4trackStruc.rew4unInd = rew4unInd;
    catch
        disp('Problem processing randRew (prob none present');
    end
    
    % now need to integrate rewDelay stuff from unitRew4DelayCaMouse.m
    try
    % from unitEpochSortItiPropMouse.m
    rewEpRate = unitEpochStruc.rewEpRate;
    rewEpRate2 = unitEpochStruc.rewEpRate2;
    rewEpRateAdj = unitEpochStruc.rewEpRateAdj;
    rewEpRate2Adj = unitEpochStruc.rewEpRate2Adj;
    
    prestimRate = unitEpochStruc.rewEpRate(rew4unInd,1);
    poststimRate = unitEpochStruc.rewEpRate(rew4unInd,2);
    
    % from unitRewEpRate2cell.m
    % rewEpRateMat = concat of all types of rewEpRates
    rewEpRateMat = cat(3, rewEpRate, rewEpRate2);
    rewEpRateMat = cat(3, rewEpRateMat, rewEpRateAdj);
    rewEpRateMat = cat(3, rewEpRateMat, rewEpRate2Adj);
    
    rbp4unitEpochStruc(i).rew4trackStruc.rewEpRateMat = rewEpRateMat;
    
    catch
    end
    %%  
    
    
    % from randRewUnitsBySessionR103R112_092415a.m
    %rewEpRateMat = unitRew4DelayStats.rewEpRateMat(:,:,1)*4;
    %unitRandRewPval = unitRew4DelayStats.unitRandRewPval;
    
    try
    [unitRewTrackStruc] = calcUnitRewTrack(segStruc, goodSeg);
    segDiffInd = unitRewTrackStruc.segDiffInd;
    rbp4unitEpochStruc(i).rew4trackStruc.segDiffInd = segDiffInd;
    rbp4unitEpochStruc(i).rew4trackStruc.rewStimCa = unitRewTrackStruc.rewStimCa;
    
    rbp4unitEpochStruc(i).rew4trackStruc.randRewUnitInd = find(unitRandRewPval <= 0.05);
    rbp4unitEpochStruc(i).rew4trackStruc.rewTrackUnitInd = find(segDiffInd <= 1);
    rbp4unitEpochStruc(i).rew4trackStruc.bothRewUnitInd = intersect(randRewUnitInd, rewTrackUnitInd);
    
    
    rbp4unitEpochStruc(i).rew4trackStruc.numSplusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))>1));
    rbp4unitEpochStruc(i).rew4trackStruc.numSminusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))<1));
    catch
    end
    % from unitRew4DelayCaMouse.m
    
%     try
%         eventType = 'isoLickTime';
%         [hitFAeventCa, missCReventCa] = unitHitFAmissCRca(dendriteBehavStruc, segStruc, eventType);
%         unitRew4DelayStruc.hitFAeventCa{totalSessNum} = squeeze(hitFAeventCa(:,goodSeg,:));
%         unitRew4DelayStruc.missCReventCa{totalSessNum} = squeeze(missCReventCa(:,goodSeg,:));
%     catch
%         disp('Could not calculate hitFAmissCR for this session');
%     end
    
end