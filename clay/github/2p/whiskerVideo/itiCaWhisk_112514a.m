
% This script finds the whisking (from whisker video) and calcium extracted from
% dendriteBehavStruc and whiskBehavStruc during ITI periods with and
% without random rewards

% NOTE: that this only is for average calcium and whisking for
% scatterplots- not bout-triggered calcium

% NOTE: that this now works only for 2014-09-13-001

% load in the relevant variables from calcium structure
eventStruc = dendriteBehavStruc.eventStruc;
stimTrigTime = eventStruc.stimTrigTime;
rewTime4 = eventStruc.rewTime4;

% look for indices of stimTrigTimes right after random rewards
stimAfterRand = knnsearch(stimTrigTime, rewTime4); % these are stims beside (i.e. just after) random rewards

cleanItiInd = setxor(stimAfterRand, 1:length(stimTrigTime)); % these are ones that are not

% now extract the calcium signals for the diff trial types
rewCa = dendriteBehavStruc.rewStimStimIndCa;
unrewCa = dendriteBehavStruc.unrewStimStimIndCa;

rewWhisk = whiskBehavStruc.rewStimStimIndWhiskSig;
unrewWhisk = whiskBehavStruc.unrewStimStimIndWhiskSig;

% need to reconstruct calcium for all trial ITIs by putting together rewCa
% and unrewCa (I didn't save calcium signals for all trials together, but
% we will need this for looking through all ITIs)
stimType = eventStruc.stimType;
rewInd = find(stimType == 1);
unrewInd = find(stimType == 2);

allStimCa = zeros(33,length(stimType));
allStimCa(:,rewInd) = rewCa;
allStimCa(:,unrewInd) = unrewCa;

cleanStimCa = allStimCa(:,cleanItiInd);
cleanItiCa = cleanStimCa(1:8, :);
randItiCa = allStimCa(:,stimAfterRand);

% now for whisking
allStimWhisk = zeros(2401,length(stimType));
allStimWhisk(:,rewInd) = rewWhisk;
allStimWhisk(:,unrewInd) = unrewWhisk;

cleanStimWhisk = allStimWhisk(:,cleanItiInd);
cleanItiWhisk = cleanStimWhisk(1:600, :);
randItiWhisk = allStimWhisk(:,stimAfterRand);