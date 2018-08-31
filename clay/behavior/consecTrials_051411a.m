% want to compute error rates based upon order of consecutive trials of
% same type

% initialize variables
n = 12; 
stimTypeArr = correctRespStruc(1,n).stimTypeArr;
corrRespArr = correctRespStruc(1,n).corrRespArr;
prevStimType = 0;
numConsec = 1;

% loop through all trials to find consecutive trials of same type
for i = 1:length(stimTypeArr)
    stimType = stimTypeArr(i);
    if stimType == prevStimType
        numConsec = numConsec+1;
    else 
        numConsec = 1;
    end
    
    consecNumArr(i) = numConsec;    % this variable contains order of consec. trials
    prevStimType = stimType;
    
end

%%
% for j = 1:length(consecNumArr)
    firstInds = find(consecNumArr==1);
    secondInds = find(consecNumArr == 2);
    thirdInds = find(consecNumArr==3);
    
    % this finds the fraction of correct responses for first second and
    % third consecutive trials of both types
    firstPercCorr = sum(corrRespArr(firstInds))/length(firstInds);
    secondPercCorr = sum(corrRespArr(secondInds))/length(secondInds);
    thirdPercCorr = sum(corrRespArr(thirdInds))/length(thirdInds);
    
     
%%
    % this finds the fraction correct with respect to number of trials,
    % broken down by trial type
    
    rewTrialInd = find(stimTypeArr == 1);
    unrewTrialInd = find(stimTypeArr == 2);
    consecRew = consecNumArr(rewTrialInd);     % makes array of consec trial number for rewarded trials only
    consecUnrew = consecNumArr(unrewTrialInd);     % makes array of consec trial number for rewarded trials only
    corrRewResp = corrRespArr(rewTrialInd);     % makes array of consec trial number for rewarded trials only
    corrUnrewResp = corrRespArr(unrewTrialInd);     % makes array of consec trial number for rewarded trials only
    
    

%%
    firstRewInds = find(consecRew==1);
    secondRewInds = find(consecRew == 2);
    thirdRewInds = find(consecRew==3);
    
    % this finds the fraction of correct responses for first second and
    % third consecutive trials of both types
    firstRewPercCorr = sum(corrRewResp(firstRewInds))/length(firstRewInds);
    secondRewPercCorr = sum(corrRewResp(secondRewInds))/length(secondRewInds);
    thirdRewPercCorr = sum(corrRewResp(thirdRewInds))/length(thirdRewInds);
    
%%
    firstUnrewInds = find(consecUnrew==1);
    secondUnrewInds = find(consecUnrew == 2);
    thirdUnrewInds = find(consecUnrew==3);
    
    % this finds the fraction of correct responses for first second and
    % third consecutive trials of both types
    firstUnrewPercCorr = sum(corrUnrewResp(firstUnrewInds))/length(firstUnrewInds);
    secondUnrewPercCorr = sum(corrUnrewResp(secondUnrewInds))/length(secondUnrewInds);
    thirdUnrewPercCorr = sum(corrUnrewResp(thirdUnrewInds))/length(thirdUnrewInds);