function [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg);  %, scaleRoiHist)

% USAGE: [epRate] = unitEpochClassif(segStruc, goodSeg);
% script to classify units based upon activity in different epochs



% load in segStruc

C = segStruc.C;  % extract temp profiles for each segment

% load in goodSeg?



% for each goodSeg unit in segStruc
% take the roiHist field (for rewStimStimInd?)
% and sum the event counts within different epochs
% 1-5
% 6-10
% 11-15
% 16-20
% 21-25
%

unitEpochStruc.filename = segStruc.filename;
unitEpochStruc.segDate = segStruc.segDate;
unitEpochStruc.goodSeg = goodSeg;
%unitEpochStruc.scaleRoiHist = scaleRoiHist;

for numSeg = 1:length(goodSeg)
    
    seg = goodSeg(numSeg);
    
    rewRoiHist = segStruc.rewStimStimIndRoiHist(:,seg);
    rewRoiHist2 = segStruc.rewStimStimIndRoiHist2(:,seg);
    unrewRoiHist = segStruc.unrewStimStimIndRoiHist(:,seg);
    unrewRoiHist2 = segStruc.unrewStimStimIndRoiHist2(:,seg);
    
    % subtract the mean firing rate
    % AND divide by the mean firing rate?
    
    roiPkRate = segStruc.roiPkRate(seg);
    numRewTrials = size(segStruc.rewStimStimIndCa, 3);
    numUnrewTrials = size(segStruc.unrewStimStimIndCa, 3);
    
    % scale by overall rate
    %if scaleRoiHist == 1
        rewRoiHistAdj = ((rewRoiHist/numRewTrials) - roiPkRate)/roiPkRate;
        rewRoiHist2Adj = ((rewRoiHist2/numRewTrials) - roiPkRate)/roiPkRate;
        unrewRoiHistAdj = ((unrewRoiHist/numUnrewTrials) - roiPkRate)/roiPkRate;
        unrewRoiHist2Adj = ((unrewRoiHist2/numUnrewTrials) - roiPkRate)/roiPkRate;
        %unitEpochStruc.scaleRoiHist = 1;
    %else
        rewRoiHistUnadj = rewRoiHist/numRewTrials;
        rewRoiHist2Unadj = rewRoiHist2/numRewTrials;
        unrewRoiHistUnadj = unrewRoiHist/numUnrewTrials;
        unrewRoiHist2Unadj = unrewRoiHist2/numUnrewTrials;
        %unitEpochStruc.scaleRoiHist = 0;
    %end
    
    for epoch = 1:4
        rewEpRateAdj(numSeg, epoch) = mean(rewRoiHistAdj(((epoch-1)*6+4):(epoch*6+3)),1); % 070317: was +4,+3
        rewEpRate2Adj(numSeg, epoch) = mean(rewRoiHist2Adj(((epoch-1)*6+4):(epoch*6+3)),1);
        unrewEpRateAdj(numSeg, epoch) = mean(unrewRoiHistAdj(((epoch-1)*6+4):(epoch*6+3)),1);
        unrewEpRate2Adj(numSeg, epoch) = mean(unrewRoiHist2Adj(((epoch-1)*6+4):(epoch*6+3)),1);
        
        rewEpRate(numSeg, epoch) = mean(rewRoiHistUnadj(((epoch-1)*6+4):(epoch*6+3)),1);
        rewEpRate2(numSeg, epoch) = mean(rewRoiHist2Unadj(((epoch-1)*6+4):(epoch*6+3)),1);
        unrewEpRate(numSeg, epoch) = mean(unrewRoiHistUnadj(((epoch-1)*6+4):(epoch*6+3)),1);
        unrewEpRate2(numSeg, epoch) = mean(unrewRoiHist2Unadj(((epoch-1)*6+4):(epoch*6+3)),1);
        
    end
    
    % NOTE: all rates are in events/frame, so *fps for events/sec
    
    % 
    rewRoiHistAdjArr(numSeg,:) = rewRoiHistAdj;
    rewRoiHist2AdjArr(numSeg,:) = rewRoiHist2Adj;
    unrewRoiHistAdjArr(numSeg,:) = unrewRoiHistAdj;
    unrewRoiHist2AdjArr(numSeg,:) = unrewRoiHist2Adj;
    
    rewRoiHistArr(numSeg,:) = rewRoiHistUnadj;
    rewRoiHist2Arr(numSeg,:) = rewRoiHist2Unadj;
    unrewRoiHistArr(numSeg,:) = unrewRoiHistUnadj;
    unrewRoiHist2Arr(numSeg,:) = unrewRoiHist2Unadj;
    
    % save parameters for each unit
    
    % unitClassifStruc;
    
end


% 
unitEpochStruc.rewRoiHistAdjArr = rewRoiHistAdjArr;
unitEpochStruc.rewRoiHist2AdjArr = rewRoiHist2AdjArr;
unitEpochStruc.unrewRoiHistAdjArr = unrewRoiHistAdjArr;
unitEpochStruc.unrewRoiHist2AdjArr = unrewRoiHist2AdjArr;

unitEpochStruc.rewRoiHistArr = rewRoiHistArr;
unitEpochStruc.rewRoiHist2Arr = rewRoiHist2Arr;
unitEpochStruc.unrewRoiHistArr = unrewRoiHistArr;
unitEpochStruc.unrewRoiHist2Arr = unrewRoiHist2Arr;

% these are normalized for mean firing rate (NOT z-scored)
unitEpochStruc.rewEpRateAdj = rewEpRateAdj;
unitEpochStruc.rewEpRate2Adj = rewEpRate2Adj;
unitEpochStruc.unrewEpRateAdj = unrewEpRateAdj;
unitEpochStruc.unrewEpRate2Adj = unrewEpRate2Adj;

% these are unadjusted for mean firing rate
unitEpochStruc.rewEpRate = rewEpRate;
unitEpochStruc.rewEpRate2 = rewEpRate2;
unitEpochStruc.unrewEpRate = unrewEpRate;
unitEpochStruc.unrewEpRate2 = unrewEpRate2;



clear rewEpRate rewEpRateAdj rewEpRate2 rewEpRate2Adj unrewEpRate unrewEpRateAdj unrewEpRate2 unrewEpRate2Adj;
clear rewRoiHistArr rewRoiHistAdjArr rewRoiHist2Arr rewRoiHist2AdjArr unrewRoiHistArr unrewRoiHistAdjArr unrewRoiHist2Arr unrewRoiHist2AdjArr;