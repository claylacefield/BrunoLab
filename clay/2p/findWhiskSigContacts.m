function [eventStruc] = findWhiskSigContacts(eventStruc, whiskSig1, whiskSig2, itiStruc)


stimTrig = eventStruc.stimTrigTime;
rewStimInd = eventStruc.rewStimStimInd;
unrewStimInd = eventStruc.unrewStimStimInd;

correctRewStimInd = eventStruc.correctRewStimInd;
incorrectRewStimInd = eventStruc.incorrectRewStimInd;
correctUnrewStimInd = eventStruc.correctUnrewStimInd;
incorrectUnrewStimInd = eventStruc.incorrectUnrewStimInd;

%% Find whisker contacts (BOT stim)
try
    [trialContactCell1] = findWhiskSigContactsSub(whiskSig1, stimTrig, rewStimInd, itiStruc);
    
    whiskContacts1 = [];
    for i = 1:length(trialContactCell1)
        whiskContacts1 = [whiskContacts1; trialContactCell1{i}];
    end
    
    eventStruc.whiskContactTime1 = whiskContacts1;
    
    clear whiskSig1;
    
    try
        whiskContactCell1 = cell(length(stimTrig),1);
        whiskContactCell1(rewStimInd) = trialContactCell1;
    catch
    end
    
    firstContactArr1 = [];
    for j = 1:length(whiskContactCell1)
        try
            contacts = whiskContactCell1{j};
            firstContactArr1 = [firstContactArr1 contacts(1)];
        catch
            firstContactArr1 = [firstContactArr1 0];
        end
    end
    eventStruc.whiskContactCell1 = whiskContactCell1;
    eventStruc.firstContactArr1 =  firstContactArr1;  % NOTE: this includes "0"s for all trials with no contacts
    firstContactTimes1 = firstContactArr1(firstContactArr1 ~= 0);
    eventStruc.firstContactTimes1 = firstContactTimes1; % and this doesn't
    
    
    corrRewFirstContactTimes1 = firstContactArr1(correctRewStimInd);  % corrRewInd); % changed 011216
    eventStruc.corrRewFirstContactTimes1 = corrRewFirstContactTimes1(corrRewFirstContactTimes1 ~= 0);
    incorrRewFirstContactTimes1 = firstContactArr1(incorrectRewStimInd);  % incorrRewInd);
    eventStruc.incorrRewFirstContactTimes1 = incorrRewFirstContactTimes1(incorrRewFirstContactTimes1 ~= 0);
    corrUnrewFirstContactTimes1 = firstContactArr1(correctUnrewStimInd);  % corrUnrewInd);
    eventStruc.corrUnrewFirstContactTimes1 = corrUnrewFirstContactTimes1(corrUnrewFirstContactTimes1 ~= 0);
    incorrUnrewFirstContactTimes1 = firstContactArr1(incorrectUnrewStimInd);  % incorrUnrewInd);
    eventStruc.incorrUnrewFirstContactTimes1 = incorrUnrewFirstContactTimes1(incorrUnrewFirstContactTimes1 ~= 0);
    
catch
    disp('Cannot process BOT whisker contacts');
end

%% now for other whisker signal (TOP stim)
try
    [trialContactCell2] = findWhiskSigContactsSub(whiskSig2, stimTrig, unrewStimInd, itiStruc);
    
    whiskContacts2 = [];
    for i = 1:length(trialContactCell2)
        whiskContacts2 = [whiskContacts2; trialContactCell2{i}];
    end
    
    eventStruc.whiskContactTime2 = whiskContacts2;
    
    clear whiskSig2;
    
    %% and find first TOP/BOT whisker contacts in each trial (as of May2013 this is TOP stim)
    
    try
        whiskContactCell2 = cell(length(stimTrig),1);
        whiskContactCell2(unrewStimInd) = trialContactCell2;
    catch
    end
    
    firstContactArr2 = [];
    for j = 1:length(whiskContactCell2)
        try
            contacts = whiskContactCell2{j};
            firstContactArr2 = [firstContactArr2 contacts(1)];
        catch
            firstContactArr2 = [firstContactArr2 0];
        end
    end
    
    eventStruc.whiskContactCell2 = whiskContactCell2;
    eventStruc.firstContactArr2 =  firstContactArr2;
    firstContactTimes2 = firstContactArr2(firstContactArr2 ~= 0);
    eventStruc.firstContactTimes2 = firstContactTimes2;
    
    %% Separating based upon trial type and response
    
    corrRewFirstContactTimes2 = firstContactArr2(correctRewStimInd);  % corrRewInd);
    eventStruc.corrRewFirstContactTimes2 = corrRewFirstContactTimes2(corrRewFirstContactTimes2 ~= 0);
    incorrRewFirstContactTimes2 = firstContactArr2(incorrectRewStimInd);  % incorrRewInd);
    eventStruc.incorrRewFirstContactTimes2 = incorrRewFirstContactTimes2(incorrRewFirstContactTimes2 ~= 0);
    corrUnrewFirstContactTimes2 = firstContactArr2(correctUnrewStimInd);  % corrUnrewInd);
    eventStruc.corrUnrewFirstContactTimes2 = corrUnrewFirstContactTimes1(corrUnrewFirstContactTimes2 ~= 0);
    incorrUnrewFirstContactTimes2 = firstContactArr2(incorrectUnrewStimInd);  % incorrUnrewInd);
    eventStruc.incorrUnrewFirstContactTimes2 = incorrUnrewFirstContactTimes2(incorrUnrewFirstContactTimes2 ~= 0);
    
catch
    disp('Cannot process TOP whisker contacts');
end
