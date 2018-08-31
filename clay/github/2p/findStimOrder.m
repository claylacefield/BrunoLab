function [eventStruc] = findStimOrder(eventStruc)

%% USAGE: [stimOrderStruc] = findStimOrder(eventStruc);
% this script looks through all trials and separates trials based upon how
% many of a particular trial type come before it (i.e. if it's a forced
% trial type switch, when an animal might better be able to predict the
% next trial type).



stimTypeArr = eventStruc.stimType;
rewStimStimInd = eventStruc.rewStimStimInd;
unrewStimStimInd = eventStruc.unrewStimStimInd;

% few initial values
numConsec = 1;
stimOrderArr(1) = 1;
prevStimType = stimTypeArr(1);
firstAfterArr(1) = 0;

% see what order each stim (of both types)
for stimNum = 2:length(stimTypeArr)
    
    stimType = stimTypeArr(stimNum);
    
    if stimType == prevStimType
        numConsec = numConsec + 1;
        stimOrderArr(stimNum) = numConsec;
        firstAfterArr(stimNum) = 0;
    else
    
    firstAfterArr(stimNum) = numConsec; % for each first stim of a type, how many of other stim did it follow      
    stimOrderArr(stimNum) = 1; 
    numConsec = 1;
    
    end
    
    prevStimType = stimType;
end

% this finds stim ind of partic order stim (both types)
order1StimInd = find(stimOrderArr==1);
order2StimInd = find(stimOrderArr==2);
order3StimInd = find(stimOrderArr==3);

eventStruc.order1rewStimInd = intersect(order1StimInd, rewStimStimInd);
eventStruc.order2rewStimInd = intersect(order2StimInd, rewStimStimInd);
eventStruc.order3rewStimInd = intersect(order3StimInd, rewStimStimInd);

eventStruc.order1unrewStimInd = intersect(order1StimInd, unrewStimStimInd);
eventStruc.order2unrewStimInd = intersect(order2StimInd, unrewStimStimInd);
eventStruc.order3unrewStimInd = intersect(order3StimInd, unrewStimStimInd);


% this finds stims after prev stim of a particular number (both types)
firstAfter1StimInd = find(firstAfterArr==1);
firstAfter2StimInd = find(firstAfterArr==2);
firstAfter3StimInd = find(firstAfterArr==3);

eventStruc.firstRewAfter1unrewStimInd = intersect(firstAfter1StimInd, rewStimStimInd);
eventStruc.firstRewAfter2unrewStimInd = intersect(firstAfter2StimInd, rewStimStimInd);
eventStruc.firstRewAfter3unrewStimInd = intersect(firstAfter3StimInd, rewStimStimInd);

eventStruc.firstUnrewAfter1rewStimInd = intersect(firstAfter1StimInd, unrewStimStimInd);
eventStruc.firstUnrewAfter2rewStimInd = intersect(firstAfter2StimInd, unrewStimStimInd);
eventStruc.firstUnrewAfter3rewStimInd = intersect(firstAfter3StimInd, unrewStimStimInd);

% % get order for each rew stim ind
% rewStimOrder = stimOrderArr(rewStimStimInd);
% unrewStimOrder = stimOrderArr(unrewStimStimInd);
% 
% order1rewStimInd = find(rewStimOrder==1);
% order2rewStimInd = find(rewStimOrder==2);
% order3rewStimInd = find(rewStimOrder==3);
% 
% order1unrewStimInd = find(unrewStimOrder==1);
% order2unrewStimInd = find(unrewStimOrder==2);
% order3unrewStimInd = find(unrewStimOrder==3);



