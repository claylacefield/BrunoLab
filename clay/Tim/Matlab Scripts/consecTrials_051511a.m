function [consecTrialStruc] = consecTrials(correctRespStruc);

% CLAY ~5/15/11
% want to compute error rates based upon order of consecutive trials of
% same type

%% LOOP THROUGH ALL ANIMALS FROM THIS DAY AND COMPUTE ACCURACY OF CONSEC
%% TRIALS

% initialize variables
for n = 1:length(correctRespStruc)
    if length(correctRespStruc(1,n).stimTypeArr)>0  % check to make sure that there is data in this location
        stimTypeArr = correctRespStruc(1,n).stimTypeArr;    % and load in variables of stimulus type
        corrRespArr = correctRespStruc(1,n).corrRespArr;    % and whether response to this stim is correct
        prevStimType = 0;   % initialize 
        numConsec = 1;  % counter for curr num of consec trials of any type

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

%% FIND INDICES OF CONSEC TRIALS AND COMPUTE ACCURACY FOR EACH
        % for j = 1:length(consecNumArr)
        firstInds = find(consecNumArr==1);
        secondInds = find(consecNumArr == 2);
        thirdInds = find(consecNumArr==3);

        % this finds the fraction of correct responses for first second and
        % third consecutive trials of both types
        firstPercCorr(n) = sum(corrRespArr(firstInds))/length(firstInds);
        secondPercCorr(n) = sum(corrRespArr(secondInds))/length(secondInds);
        thirdPercCorr(n) = sum(corrRespArr(thirdInds))/length(thirdInds);


%% ACCURACY OF CONSEC TRIALS OF REW VS. UNREW

        % this finds the fraction correct with respect to number of trials,
        % broken down by trial type

        rewTrialInd = find(stimTypeArr == 1);
        unrewTrialInd = find(stimTypeArr == 2);
        consecRew = consecNumArr(rewTrialInd);     % makes array of consec trial number for rewarded trials only
        consecUnrew = consecNumArr(unrewTrialInd);     % makes array of consec trial number for rewarded trials only
        corrRewResp = corrRespArr(rewTrialInd);     % makes array of consec trial number for rewarded trials only
        corrUnrewResp = corrRespArr(unrewTrialInd);     % makes array of consec trial number for rewarded trials only



%% REWARDED
        firstRewInds = find(consecRew==1);
        secondRewInds = find(consecRew == 2);
        thirdRewInds = find(consecRew==3);

        % this finds the fraction of correct responses for first second and
        % third consecutive trials of both types
        firstRewPercCorr(n) = sum(corrRewResp(firstRewInds))/length(firstRewInds);
        secondRewPercCorr(n) = sum(corrRewResp(secondRewInds))/length(secondRewInds);
        thirdRewPercCorr(n) = sum(corrRewResp(thirdRewInds))/length(thirdRewInds);

%% UNREWARDED
        firstUnrewInds = find(consecUnrew==1);
        secondUnrewInds = find(consecUnrew == 2);
        thirdUnrewInds = find(consecUnrew==3);

        % this finds the fraction of correct responses for first second and
        % third consecutive trials of both types
        firstUnrewPercCorr(n) = sum(corrUnrewResp(firstUnrewInds))/length(firstUnrewInds);
        secondUnrewPercCorr(n) = sum(corrUnrewResp(secondUnrewInds))/length(secondUnrewInds);
        thirdUnrewPercCorr(n) = sum(corrUnrewResp(thirdUnrewInds))/length(thirdUnrewInds);
        
        consecNumCel{n} = consecNumArr;
        names{n}= correctRespStruc(1,n).name;
        
        % clear variables before processing next animal
        clear consecNumArr firstInds secondInds thirdInds firstRewInds secondRewInds thirdRewInds firstUnrewInds secondUnrewInds thirdUnrewInds corrRewResp corrUnrewResp;

    end
end

%% NOW SAVE ALL RELEVANT VARIABLES INTO STRUCTURE

consecTrialStruc.names = names;
consecTrialStruc.consecNumCel = consecNumCel;
consecTrialStruc.firstPercCorr = firstPercCorr;
consecTrialStruc.secondPercCorr = secondPercCorr;
consecTrialStruc.thirdPercCorr= thirdPercCorr;
consecTrialStruc.firstRewPercCorr = firstRewPercCorr;
consecTrialStruc.secondRewPercCorr = secondRewPercCorr;
consecTrialStruc.thirdRewPercCorr= thirdRewPercCorr;
consecTrialStruc.firstUnrewPercCorr = firstUnrewPercCorr;
consecTrialStruc.secondUnrewPercCorr = secondUnrewPercCorr;
consecTrialStruc.thirdUnrewPercCorr= thirdUnrewPercCorr;