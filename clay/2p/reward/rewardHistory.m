

% new script for reward history analysis

% question: are calcium signals affected by prior reward
% so, there are 2 types of rewards
% 1.) trial rewards
% 2.) random rewards

% so for random rewards
% find the times of random rewards, find the trial index immediately after

% extract relevant trial info
rewTime4 = eventStruc.rewTime4;
stimTrigTime = eventStruc.stimTrigTime;
stimTypeArr = eventStruc.correctRespStruc.stimTypeArr;
corrRespArr = eventStruc.correctRespStruc.corrRespArr;


% find trials following rewards
for numRew = 1:length(rewTime4)
    postRewTrial(numRew) = find(stimTrigTime > rewTime4(numRew), 1,'first');
end


% now want to separate calcium responses based upon trial type and correct
postRewTrialType = stimTypeArr(postRewTrial);
postRewTrialCorr = corrRespArr(postRewTrial);


corrRewPostRew = postRewTrial(postRewTrialType == 1 & postRewTrialCorr == 1);
incorrRewPostRew = postRewTrial(postRewTrialType == 1 & postRewTrialCorr == 0);
corrUnrewPostRew = postRewTrial(postRewTrialType == 2 & postRewTrialCorr == 1);
incorrUnrewPostRew = postRewTrial(postRewTrialType == 2 & postRewTrialCorr == 0);



