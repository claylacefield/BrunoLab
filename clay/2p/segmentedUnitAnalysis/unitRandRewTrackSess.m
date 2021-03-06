function [unitRandRewTrackStruc] = unitRandRewTrackSess();


% Clay
% 012618

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


% load in necessary strucs
load(findLatestFilename('_dendriteBehavStruc_'));
load(findLatestFilename('_seg_'));
load(findLatestFilename('_goodSeg_'));

% but can take unitEpochStruc from input struc
[unitEpochStruc] = unitEpochClassif(segStruc, goodSeg);

% from unitEpochSortItiPropMouse.m
% for randRew units
toPlot = 0;
try
    [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot);
    %try
    %rew4unInd = unitItiPropStruc.rew4unInd; % goodSeg indices of units with rew4 pval<0.05
    unitRandRewTrackStruc.unitPropArr = unitItiPropStruc.unitPropArr;
    unitRandRewPval = unitItiPropStruc.unitRandRewPval;
    unitRandRewTrackStruc.unitRandRewPval = unitRandRewPval;
    %rew4trackStruc.rew4units = rew4unInd;
    
    randRewUnitInd = find(unitRandRewPval <= 0.02);
    unitRandRewTrackStruc.randRewUnits = randRewUnitInd;
    
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
    
    %prestimRate = unitEpochStruc.rewEpRate(rew4unInd,1);
    %poststimRate = unitEpochStruc.rewEpRate(rew4unInd,2);
    
    % from unitRewEpRate2cell.m
    % rewEpRateMat = concat of all types of rewEpRates
    % unit# x epoch x type (pkMeth1 pkMeth2 adjForMean1 adjForMean2)
    rewEpRateMat = cat(3, rewEpRate, rewEpRate2);
    rewEpRateMat = cat(3, rewEpRateMat, rewEpRateAdj);
    rewEpRateMat = cat(3, rewEpRateMat, rewEpRate2Adj);
    
    unitRandRewTrackStruc.rewEpRateMat = rewEpRateMat;
    
    unitRandRewTrackStruc.numSplusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))>1));
    unitRandRewTrackStruc.numSminusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))<1));
    
catch
end



%%


% from randRewUnitsBySessionR103R112_092415a.m
%rewEpRateMat = unitRew4DelayStats.rewEpRateMat(:,:,1)*4;
%unitRandRewPval = unitRew4DelayStats.unitRandRewPval;

try
    [unitRewTrackStruc] = calcUnitRewTrack(segStruc, goodSeg, 0);
    %segDiffInd = unitRewTrackStruc.segDiffInd;
    %rew4trackStruc.segDiffInd = segDiffInd;
    %rbp4unitEpochStruc(i).rew4trackStruc.rewStimCa = unitRewTrackStruc.rewStimCa;
    
    unitRandRewTrackStruc.unitRewTrackStruc = unitRewTrackStruc;
    unitRandRewTrackStruc.rewTrackUnits = unitRewTrackStruc.rewTrackUnits;
    unitRandRewTrackStruc.bothRewUnitInd = intersect(randRewUnitInd, unitRewTrackStruc.rewTrackUnits);
    
    
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

clear rewEpRateMat segDiffInd randRewUnitInd unitRandRewPval ;

