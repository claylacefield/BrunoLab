function unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc)


% This script is to find the firing rate over all ITIs versus random reward
% period firing


rewTime4 = dendriteBehavStruc.eventStruc.rewTime4;
itiBegTime3 = itiBegInd2;
itiEndTime3 = itiEndInd2;

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

% now have to look in each ITI and randRew ITI to see what proportion have
% roiPks


frameTrig = dendriteBehavStruc.eventStruc.frameTrig;


for unitNum = 1:length(goodSeg)  % for all goodSegs
    roiPkFrameInds = segStruc.roiPkIndCell{goodSeg(unitNum)}; % get roiPk indices for this unit
    roiPkTimes = frameTrig(roiPkFrameInds);   % and find the times for these events 
    
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


for unitNum = 1:length(goodSeg)
    unitPropArr(unitNum,1) = sum(cleanItiUnitEventProp(unitNum,:));
    unitPropArr(unitNum,2) = length(itiBegTime3);
    unitPropArr(unitNum,3) = sum(randRewItiUnitEventProp(unitNum,:));
    unitPropArr(unitNum,4) = length(rewTime4);
end



for unitNum = 1:length(goodSeg)
    
    successes = [unitPropArr(unitNum,3) unitPropArr(unitNum,1)];
    attempts = [unitPropArr(unitNum,4) unitPropArr(unitNum,2)];
    alternative = 2;  % 2-sided
    [pval] = CompareProportions(successes, attempts, alternative);
    unitRandRewPval(unitNum) = pval;
    
end


% now plot scatter of significant units
rew4unInd = find(unitRandRewPval <= 0.05);
rew4modInd = rew4unInd(find(unitPropArr(rew4unInd,3) == 1));

figure; 
hold on; line([0 0.1], [0 0.1], 'Color', 'r');
scatter(unitEpochStruc.rewEpRate(:,1), unitEpochStruc.rewEpRate(:,2));
scatter(unitEpochStruc.rewEpRate(rew4unInd,1), unitEpochStruc.rewEpRate(rew4unInd,2), 'r');
scatter(unitEpochStruc.rewEpRate(rew4modInd,1), unitEpochStruc.rewEpRate(rew4modInd,2), 'y');

% for numIti = 1:length(itiBegInd)
%    itiFrIndCell{numIti} = find(frameTrig >= itiBegTime3(numIti) && frameTrig <= itiEndTime3(numIti)); 
%     
%     
% end








