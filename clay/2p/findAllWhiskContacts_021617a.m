function [eventStruc] = findAllWhiskContacts(eventStruc, whiskSig1, whiskSig2)

% NOTE 021917: not used right now, in favor of findWhiskSigContacts.m

%% Find whisker contacts (BOT stim)
[whiskContacts1] = detectWhiskContacts(whiskSig1);

eventStruc.whiskContactTime1 = whiskContacts1;

clear whiskSig1; % filtWhiskSig1;

%% now for other whisker signal (TOP stim)

%whiskContacts2 = [];

filtWhiskSig2 = whiskSig2 - runmean(whiskSig2, 20);  % 071913: now subtracting running mean instead of filtering

%timeoutMs = 10;  % how many ms minimum between whisk touches
%timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh2 = 4*std(filtWhiskSig2)+0.4;  % stdev threshold for whisker touch detection
    
whiskContacts2 = LocalMinima(-filtWhiskSig2,timeoutSamp, -stdThresh2);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));

eventStruc.whiskContactTime2 = whiskContacts2;

clear whiskSig2; % filtWhiskSig2;


%% and find first TOP/BOT whisker contacts in each trial (as of May2013 this is TOP stim)

afterStim = 320; % 300: samples to wait after stim trig to avoid stim artifact

% select out regions during stimulus epochs to look for whisker contacts
% (this is an array)
stimEpochStart = stimTrig + afterStim; % + sf/20;   % start looking for whisker contacts after motor artifact should have ended
stimEpochEnd = stimEpochStart + 2.7*sf;  % and stop just before the end motor artifact


whiskContactCell1 = {};
firstContactArr1 = [];  % change to = zeros(length(stimTrig), 1); for speed (but shouldn't matter much)
whiskContactCell2 = {};
firstContactArr2 = [];

for k = 1:length(stimTrig)   % so for each stimulus trigger in the corresponding stimulus epoch
    
    % select out trial epoch of whisker contacts (based upon trial triggers)   
    whiskContactTrial1 = whiskContacts1(whiskContacts1 >= stimEpochStart(k) & whiskContacts1 <= stimEpochEnd(k));
    whiskContactTrial2 = whiskContacts2(whiskContacts2 >= stimEpochStart(k) & whiskContacts2 <= stimEpochEnd(k));
    
    % now concatenate the latest whisker contacts with the previous
    if ~isempty(whiskContactTrial1)
        %whiskContactTrial1 = whiskContactTrial1 + afterStim;  % now adjusted for time since start of this trial
        whiskContactCell1{k} = whiskContactTrial1;   % and put in cell array (since can be diff num of touches in each trial)
        %whiskContactTrialAdj1 = whiskContactTrial1+stimTrig(k);   % this gives absolute time of touches (vs. whole session) in this trial
        %whiskContacts1 = vertcat(whiskContacts1, whiskContactTrialAdj1); % and concatenate with all other trials
        % NOTE 072213: time now already adjusted when isolating already
        % detected contacts for each trial
        
        firstContact1 = whiskContactTrial1(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr1(k) = firstContact1;  % array of first contact times (relative to trial)
    else
        whiskContactCell1{k} = 0;  % don't know if I need this
        firstContactArr1(k) = 0;        
    end
    
    if ~isempty(whiskContactTrial2)
        whiskContactCell2{k} = whiskContactTrial2;   % and put in cell array (since can be diff num of touches in each trial)

        firstContact2 = whiskContactTrial2(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr2(k) = firstContact2;  % array of first contact times (relative to trial)
    else
        whiskContactCell2{k} = 0;  % don't know if I need this
        firstContactArr2(k) = 0;
    end
    
end

eventStruc.whiskContactCell1 = whiskContactCell1;
eventStruc.firstContactArr1 =  firstContactArr1;  % NOTE: this includes "0"s for all trials with no contacts
firstContactTimes1 = firstContactArr1(firstContactArr1 ~= 0);
eventStruc.firstContactTimes1 = firstContactTimes1; % and this doesn't 

eventStruc.whiskContactCell2 = whiskContactCell2;
eventStruc.firstContactArr2 =  firstContactArr2;
firstContactTimes2 = firstContactArr2(firstContactArr2 ~= 0);
eventStruc.firstContactTimes2 = firstContactTimes2;

corrRewFirstContactTimes1 = firstContactArr1(corrRewInd);
eventStruc.corrRewFirstContactTimes1 = corrRewFirstContactTimes1(corrRewFirstContactTimes1 ~= 0);
incorrRewFirstContactTimes1 = firstContactArr1(incorrRewInd);
eventStruc.incorrRewFirstContactTimes1 = incorrRewFirstContactTimes1(incorrRewFirstContactTimes1 ~= 0);
corrUnrewFirstContactTimes1 = firstContactArr1(corrUnrewInd);
eventStruc.corrUnrewFirstContactTimes1 = corrUnrewFirstContactTimes1(corrUnrewFirstContactTimes1 ~= 0);
incorrUnrewFirstContactTimes1 = firstContactArr1(incorrUnrewInd);
eventStruc.incorrUnrewFirstContactTimes1 = incorrUnrewFirstContactTimes1(incorrUnrewFirstContactTimes1 ~= 0);

corrRewFirstContactTimes2 = firstContactArr2(corrRewInd);
eventStruc.corrRewFirstContactTimes2 = corrRewFirstContactTimes2(corrRewFirstContactTimes2 ~= 0);
incorrRewFirstContactTimes2 = firstContactArr2(incorrRewInd);
eventStruc.incorrRewFirstContactTimes2 = incorrRewFirstContactTimes2(incorrRewFirstContactTimes2 ~= 0);
corrUnrewFirstContactTimes2 = firstContactArr2(corrUnrewInd);
eventStruc.corrUnrewFirstContactTimes2 = corrUnrewFirstContactTimes1(corrUnrewFirstContactTimes2 ~= 0);
incorrUnrewFirstContactTimes2 = firstContactArr2(incorrUnrewInd);
eventStruc.incorrUnrewFirstContactTimes2 = incorrUnrewFirstContactTimes2(incorrUnrewFirstContactTimes2 ~= 0);


%% (Should just extract the following in the dendriteBehavior analysis script??? or integrate skip events...)
% % now find first contact times for correct and incorrect rewarded trials
% corrFirstContactTimes1 = firstContactArr1(corrRewInd);
% incorrFirstContactTimes1 = firstContactArr1(incorrRewInd);
% incorrFirstContactTimes1 = incorrFirstContactTimes1(incorrFirstContactTimes ~= 0);
% 
% eventStruc.corrFirstContactTimes1 = corrFirstContactTimes1;
% eventStruc.incorrFirstContactTimes1 = incorrFirstContactTimes1;
% 
% % now save whiskSig2 data
% 
% % now find first contact times for correct and incorrect rewarded trials
% corrFirstContactTimes2 = firstContactArr2(corrRewInd);
% incorrFirstContactTimes2 = firstContactArr2(incorrRewInd);
% incorrFirstContactTimes2 = incorrFirstContactTimes2(incorrFirstContactTimes ~= 0);
% 
% eventStruc.corrFirstContactTimes2 = corrFirstContactTimes2;
% eventStruc.incorrFirstContactTimes2 = incorrFirstContactTimes2;

