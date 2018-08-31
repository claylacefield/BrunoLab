function [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot)

%% USAGE: [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot);

% This script is to find the firing rate over all ITIs versus random reward
% period firing

% go ahead and save filename, seg date, etc.
unitItiPropStruc.filename = segStruc.filename;
unitItiPropStruc.segDate = segStruc.segDate;
unitItiPropStruc.goodSeg = goodSeg;
unitItiPropStruc.txtName = dendriteBehavStruc.eventStruc.correctRespStruc.name; % name of text file
unitItiPropStruc.analDate = date; % date of this analysis

% find ITIs
toPlot = 0;
[itiStruc] = findITIs(dendriteBehavStruc, toPlot);
unitItiPropStruc.itiStruc = itiStruc;

% load in times of randRew and ITIs
rewTime4 = dendriteBehavStruc.eventStruc.rewTime4;
itiBegTime3 = itiStruc.itiBegInd;
itiEndTime3 = itiStruc.itiEndInd;

% find the indices of ITIs with a random rew, then filter them out
for numRandRew = 1:length(rewTime4)
    [val, ind] = min(abs(itiEndTime3-rewTime4(numRandRew)));
    randRewItiInd(numRandRew) = ind;
    randRewItiBegTime(numRandRew) = itiBegTime3(ind);
    randRewItiEndTime(numRandRew) = itiEndTime3(ind);
    itiBegTime3 = itiBegTime3([1:ind-1 ind+1:end]); % now filter these out of the iti list
    itiEndTime3 = itiEndTime3([1:ind-1 ind+1:end]);
end

% itiBeg/EndTime3 now consists of beginning and ending times for all ITIs
% with no randRew

%% Look in each ITI and randRew epoch to see what proportion have roiPks

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;

cleanItiUnitEventProp = []; randRewItiUnitEventProp = [];

for unitNum = 1:length(goodSeg)  % for all goodSegs
    roiPkFrameInds = segStruc.roiPkIndCell{goodSeg(unitNum)}; % get roiPk indices for this unit
    roiPkTimes = frameTrig(roiPkFrameInds);   % and find the times for these events 
    
    cleanItiPk = []; randRewPk = [];
    
    % find proportion of clean ITIs with roiPks
    for itiNum = 1:length(itiBegTime3)   % then for all ITIs
        if ~isempty(find(roiPkTimes >= itiBegTime3(itiNum) & roiPkTimes <= itiEndTime3(itiNum))) % find roiPks during these times
            cleanItiPk(itiNum) = 1;
        else
            cleanItiPk(itiNum) = 0;
        end
        
    end
    
    % find proportion of randRew events with roiPks
    for randRewNum = 1:length(rewTime4)
        rewTime = rewTime4(randRewNum);  % time of this randRew
        
        % find whether there are roiPks during the period after this rew
        if ~isempty(find(roiPkTimes >= rewTime & roiPkTimes <= rewTime + 3000))
            randRewPk(randRewNum) = 1;
        else
            randRewPk(randRewNum) = 0;
        end
        
        
    end
    
    cleanItiUnitEventProp(unitNum,:) = cleanItiPk;
    randRewItiUnitEventProp(unitNum,:) = randRewPk;
    
end

unitItiPropStruc.cleanItiUnitEventProp = cleanItiUnitEventProp; % save to output struc
unitItiPropStruc.randRewItiUnitEventProp = randRewItiUnitEventProp;

%% now tabulate # epochs with calcium events and total number of epochs/trials

unitPropArr = [];

for unitNum = 1:length(goodSeg)
    unitPropArr(unitNum,1) = sum(cleanItiUnitEventProp(unitNum,:)); % # clean ITIs with a ca event
    unitPropArr(unitNum,2) = length(itiBegTime3); % total # clean ITIs
    unitPropArr(unitNum,3) = sum(randRewItiUnitEventProp(unitNum,:)); % # randRew epochs with a ca event
    unitPropArr(unitNum,4) = length(rewTime4); % total # randRew
end

unitItiPropStruc.unitPropArr = unitPropArr; % save to output structure


%% Now calcuate pvalues with CompareProportions

unitRandRewPval = [];

for unitNum = 1:length(goodSeg)
    
    successes = [unitPropArr(unitNum,3) unitPropArr(unitNum,1)];
    attempts = [unitPropArr(unitNum,4) unitPropArr(unitNum,2)];
    alternative = 2;  % 2-sided
    [pval] = CompareProportions(successes, attempts, alternative);
    unitRandRewPval(unitNum) = pval;
    
end

unitItiPropStruc.unitRandRewPval = unitRandRewPval; % save pvals to output structure


%% Plotting

pValThresh = 0.05;

% now plot scatter of significant units
rew4unInd = find(unitRandRewPval <= pValThresh);
rew4modInd = rew4unInd(find(unitPropArr(rew4unInd,3) == 1));

unitItiPropStruc.pValThresh = pValThresh;
unitItiPropStruc.rew4unInd = rew4unInd;  % and save these to output struc, just in case
unitItiPropStruc.rew4modInd = rew4modInd;

if toPlot == 1
    
    figure;
    hold on; line([0 0.1], [0 0.1], 'Color', 'r');
    scatter(unitEpochStruc.rewEpRate(:,1), unitEpochStruc.rewEpRate(:,2));
    scatter(unitEpochStruc.rewEpRate(rew4unInd,1), unitEpochStruc.rewEpRate(rew4unInd,2), 'r');
    scatter(unitEpochStruc.rewEpRate(rew4modInd,1), unitEpochStruc.rewEpRate(rew4modInd,2), 'y');
    
end
% for numIti = 1:length(itiBegInd)
%    itiFrIndCell{numIti} = find(frameTrig >= itiBegTime3(numIti) && frameTrig <= itiEndTime3(numIti)); 
%     
%     
% end

