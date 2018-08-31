function [trialContactCell] = findWhiskSigContactsSub(whiskSig, stimTrig, stimInd, itiStruc)

% so only find rewStim contacts for detection task
% but do both for discrimination task
% but calculations may be different for discrimination task
% where rew/unrew may not correspond to bot/top

stimTime = stimTrig(stimInd);

stimEpochStart = itiStruc.stimEpBegTimes;
stimEpochEnd = itiStruc.stimEpEndTimes;

% select rewStim epochs from whiskSig
for k = 1:length(stimInd)
    try
    whiskSigTrial = whiskSig(stimEpochStart(stimInd(k))+60:(stimEpochEnd(stimInd(k))-20));
    whiskSigCell{k} = whiskSigTrial;
    try
    whiskSigTrialArr(:,k) = whiskSigTrial(1:2500);
    catch
        disp('Prob sep choice');
        whiskSigTrialArr(:,k) = whiskSigTrial(1:1800);
    end
    sdWhiskSigTrial(k) = std(whiskSigTrial); % this is before mean subtraction so is imperfect
    catch
        
    end
end

% subtract mean of all epochs (in case of systematic artifacts, e.g. from
% changing light levels during stim movement)
whiskSigTrialArr2 = whiskSigTrialArr-repmat(mean(whiskSigTrialArr,2), [1 size(whiskSigTrialArr,2)]);
minSd = min(sdWhiskSigTrial);

%figure; hold on;
for k = 1:length(stimInd)
    try
    whiskSigTrial = whiskSigTrialArr2(:,k) - runmean(whiskSigTrialArr2(:,k),100);
    whiskSigTrial = runmean(whiskSigTrial,2); % get rid of fast artifacts 
    %plot(whiskSigTrial);
    trialContacts = LocalMinima(-whiskSigTrial, 20, -(3*minSd + mean(whiskSigTrial)));
    trialContactCell{k} = trialContacts + stimEpochStart(stimInd(k))+60;
    %plot(trialContacts, whiskSigTrial(trialContacts), '.r');
    catch
    end
end





