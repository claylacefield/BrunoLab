function [eventStruc] = detect2pEvents(nChannels, sf)

%%
% This function detects a variety of behavioral events recorded along with
% 2p imaging of dendrites
%
% Currently, the signals recorded on the NI USB board are:
% 1: stimulus triggers
% 2: lever press
% 3: reward
% 4: BOT whisker signal
% 5: TOP whisker signal
% 6: lick signal
% 7: galvo signal


% Changes Jan. 2013
% - changed the methods for event detection, finding the local maximum 
%   of the derivative of channels step pulse signals

%% Set various parameters

% nChannels = 7;
% sf = 1000;
Nyquist = sf/2;

%%
% Run behavioral analysis (e.g. correct and incorrect trials)

[correctRespStruc] = correctResp2p();

%% Read in data (select .bin file with GUI)

x2 = binRead2p(nChannels);

stim = x2(1,:);
levSig = x2(2,:);
rewSig = x2(3,:);
whiskSig1 = x2(4,:);
whiskSig2 = x2(5,:);
lickSig = x2(6,:);
galvoSig = x2(7,:);

if nChannels == 8
    punSig = x2(8,:);
end

clear x2;

%% Find stimulus triggers

 dStim = diff(stim);
 dStim = [0 dStim];
 stdDstim = std(dStim);
 
stimTrigThresh = 2*stdDstim;

% find beginning of start trigger step pulse (as large pos slope)
stimTrig = LocalMinima(-dStim, sf, -stimTrigThresh);

eventStruc.stimTrig = stimTrig;

clear stim dStim;

%% Find lever presses and lever lifts

% levSig = x2(2,:);

% filter lever signal (to get rid of stim artifacts, etc.)
% MyFilt2=fir1(100,50/Nyquist);
% filtLevSig = filtfilt(MyFilt2,1,levSig);

% take derivative
%dFiltLev = [0 diff(filtLevSig)];
dLevSig = [0 diff(levSig)];

% detect lever presses and lifts
levPress = LocalMinima(-dLevSig, sf/100, -2);  % LocalMinima(-dFiltLev, 10, -0.2);
levLift = LocalMinima(dLevSig, sf/100, -2);

eventStruc.levPress = levPress;
eventStruc.levLift = levLift;

clear levSig dLevSig; %filtLevSig;

%% Find rewards

dRew = [0 diff(rewSig)];

% detect reward triggers
rew = LocalMinima(-dRew, sf, -2); % LocalMinima(-dRew, 100, -0.2);

eventStruc.rewards = rew;

clear rewSig;

%% Find whisker contacts

% whiskSig1 = x2(4,:);

whiskContacts1 = [];

% whiskSig1 = whiskSig1-mean(whiskSig1);

% stdWhisk = std(whiskSig1);

% filter whisker signal
MyFilt1=fir1(100,[10 200]/Nyquist);  % [10 200]
filtWhiskSig1 = filtfilt(MyFilt1,1,whiskSig1);

timeoutMs = 10;  % how many ms minimum between whisk touches
timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh1 = 2*std(filtWhiskSig1);  % stdev threshold for whisker touch detection
    
whiskContacts1 = LocalMinima(-filtWhiskSig1, timeoutSamp, -stdThresh1);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));

eventStruc.whiskContacts1 = whiskContacts1;

clear whiskSig1 filtwhiskSig1;

%% now for other whisker signal

whiskContacts2 = [];

% whiskSig1 = whiskSig1-mean(whiskSig1);

% stdWhisk = std(whiskSig1);

% filter whisker signal

filtWhiskSig2 = filtfilt(MyFilt1,1,whiskSig2);

timeoutMs = 10;  % how many ms minimum between whisk touches
timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh2 = 2*std(filtWhiskSig2);  % stdev threshold for whisker touch detection
    
whiskContacts2 = LocalMinima(-filtWhiskSig2,timeoutSamp, -stdThresh2);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));

eventStruc.whiskContacts2 = whiskContacts2;

clear whiskSig2 filtwhiskSig2;


%% Find licks

dLick = [0 diff(lickSig)];

% detect lever presses and lifts
licks = LocalMinima(-dLick, 20, -0.5);

% NOTE: this method does a pretty good job but might miss a few licks
% because TOP whisker hits might obscure them (thus absolute thresh might
% be better)

eventStruc.licks = licks;

clear lickSig dLick;


%% Find frames (NOTE: this detects the ends of respective frames)

% galvoSig = x2(7,:);

frameTrig = LocalMinima(galvoSig, 200, -0.5);
% Note: this works for 2Hz but need to check for 4Hz, and 
% for diff angle galvo signal

eventStruc.frameTrig = frameTrig;

clear galvoSig;

%% Behavioral data
% (from vsdBehavAnalysis.m)

% use UI to pick TXT behavioral data file and analyze
%[correctRespStruc] = correctResp2p();

stimType = correctRespStruc.stimTypeArr;
corrRespArr = correctRespStruc.corrRespArr;
incorrLevPressLatency = correctRespStruc.incorrLevPressLatency;

% find indices of diff trial types
rewStimInd = find(stimType == 1);
unrewStimInd = find(stimType == 2);

% correct resp
typeXresp = stimType.*corrRespArr;  % creates array with stim type if correct and 0 if incorrect
corrRewInd = find(typeXresp == 1); % then find the indices of correct rewarded trials
corrUnrewInd = find(typeXresp == 2);    % and incorrect

% incorr resp
typeXincorr = stimType-typeXresp;   % and reverse for incorrect responses
incorrRewInd = find(typeXincorr == 1); 
incorrUnrewInd = find(typeXincorr == 2);

%% Punishment times
if nChannels == 8
    dPun = [0 diff(punSig)];
    
    % detect punishment signals
    punTime = LocalMinima(-dPun, 200, -1);
    
    clear dPun punSig;

else
% and calculate the punishment time based upon the arduino time
punTime = stimTrig(incorrUnrewInd) + incorrLevPressLatency;
end

eventStruc.rewStimInd = rewStimInd;
eventStruc.unrewStimInd = unrewStimInd;
eventStruc.corrRewInd = corrRewInd;
eventStruc.corrUnrewInd = corrUnrewInd;
eventStruc.incorrRewInd = incorrRewInd;
eventStruc.incorrUnrewInd = incorrUnrewInd;
eventStruc.punTime = punTime;

%% and find first whisker contacts in each trial

afterStim = 50; % samples to wait after stim trig to avoid stim artifact

% select out regions during stimulus epoch to look for whisker contacts
stimEpochStart = stimTrig + afterStim; % + sf/20;   % start looking for whisker contacts after motor artifact should have ended
stimEpochEnd = stimEpochStart + 1.7*sf;  % and stop just before the end motor artifact


whiskContactCell = {};
firstContactArr = [];

whiskContacts = [];
firstContactArrAbsT = [];

for k = 1:length(stimTrig)   % so for each stimulus trigger in the corresponding stimulus epoch
    
    whiskTrial = [];
    whiskContactTrial = [];
    
    
    % select out epoch of whisker signal (based upon trial triggers)
    whiskTrial = filtwhiskSig1(stimEpochStart(k):stimEpochEnd(k));  % isolate whisker signal for this stimulus trial (either type)
    % NOTE that this might fall outside of the whisker read epoch so
    % may generate error
    
    %whiskTrial = filtwhiskSig1;
    
    % detect peaks (whisker touches)
    timeoutMs = 10;  % how many ms minimum between whisk touches
    timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
    stdThresh = 0.4;  % stdev threshold for whisker touch detection
    
    whiskContactTrial = LocalMinima(-whiskTrial, 50, -0.1); 
    
    %whiskContactTrial = LocalMinima(-whiskTrial, timeoutSamp, -(stdThresh*stdWhisk));  % detects peaks using LocalMinima (Buzsaki/Harris(kmf))
    %whiskContactTrial = whiskContactTrial + stimEpochStart(k);  % adjust indices to make relative to whole recording (not just this trial)
    %NOTE: that this is slightly misaligned but shouldn't matter much
    %NOTE: now not adjusting to absolute time because trying to make
    %single-trial cells for using with linescan frames from VSD imaging
    
    
    % now concatenate the latest whisker contacts with the previous
    if length(whiskContactTrial)>0
        whiskContactTrial = whiskContactTrial + afterStim;  % now adjusted for time since start of this trial
        whiskContactCell{k} = whiskContactTrial;   % and put in cell array (since can be diff num of touches in each trial)
        whiskContactTrialAdj = whiskContactTrial+stimTrig(k);   % this gives absolute time of touches (vs. whole session) in this trial
        whiskContacts = vertcat(whiskContacts, whiskContactTrialAdj); % and concatenate with all other trials
        
        firstContact = whiskContactTrial(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr(k) = firstContact;  % array of first contact times (relative to trial)
        firstContactArrAbsT(k) = firstContact + stimTrig(k);  % array of first contact times (absolute, vs. session)
    else
        whiskContactCell{k} = 0;  % don't know if I need this
        firstContactArr(k) = 0;
        firstContactArrAbsT(k) = 0;
        
    end
    
end

firstContactTimes = firstContactArrAbsT(find(firstContactArrAbsT ~= 0));

eventStruc.firstContactArrAbsT =  firstContactArrAbsT;
eventStruc.firstContactTimes = firstContactTimes;

% now find first contact times for correct and incorrect rewarded trials
corrFirstContactTimes = firstContactArrAbsT(corrRewInd);
incorrFirstContactTimes = firstContactArrAbsT(incorrRewInd);
incorrFirstContactTimes = incorrFirstContactTimes(find(incorrFirstContactTimes ~= 0));

eventStruc.corrFirstContactTimes = corrFirstContactTimes;
eventStruc.incorrFirstContactTimes = incorrFirstContactTimes;

%% now want to:
% - import ROI profiles
% - find ROI profiles triggered on:
%   - whisker touches
%   - first whisker touches
%   - beginning of trial
%   - lever lift
%   - punishment
%   - licks
%   - correct/incorrect rewarded/catch trials















