function [eventStruc] = detect2pEvents(nChannels, skipSig, fps, sf)

%%
% This function detects a variety of behavioral events recorded along with
% 2p imaging of dendrites
%
% Currently, the signals recorded on the NI USB board are:
% 1: stimulus triggers
% 2: lever press
% 3: reward
% 4: BOT whisker signal (071313: or is it now TOP
% 5: TOP whisker signal                       BOT???)
% 6: lick signal
% 7: galvo signal


% Changes Jan. 2013
% - changed the methods for event detection, finding the local maximum 
%   of the derivative of channels step pulse signals

%% Set various parameters

% nChannels = 7;
% sf = 1000;
Nyquist = sf/2;

%% Run behavioral analysis (e.g. correct and incorrect trials)

[correctRespStruc] = correctResp2p();

%% Extract behavioral data
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

eventStruc.rewStimInd = rewStimInd;
eventStruc.unrewStimInd = unrewStimInd;
eventStruc.corrRewInd = corrRewInd;
eventStruc.corrUnrewInd = corrUnrewInd;
eventStruc.incorrRewInd = incorrRewInd;
eventStruc.incorrUnrewInd = incorrUnrewInd;

%% Read in data (select .bin file with GUI)

x2 = binRead2p(nChannels);

if skipSig ~= 0
    x2(skipSig) = 0; % this is to zero any signals for a day that might be bad
end

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

%% Find whisker contacts (TOP stim I think)

% whiskSig1 = x2(4,:);

whiskContacts1 = [];

% whiskSig1 = whiskSig1-mean(whiskSig1);

% stdWhisk = std(whiskSig1);

% filter whisker signal
MyFilt1=fir1(100,[10 200]/Nyquist);  % [10 200]
%filtWhiskSig1 = filtfilt(MyFilt1,1,whiskSig1);

filtWhiskSig1 = whiskSig1 - runmean(whiskSig1, 20);  % 071913: now subtracting running mean instead of filtering

timeoutMs = 10;  % how many ms minimum between whisk touches
timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh1 = 4*std(filtWhiskSig1);  % stdev threshold for whisker touch detection
    
whiskContacts1 = LocalMinima(-filtWhiskSig1, timeoutSamp, -stdThresh1);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));

eventStruc.whiskContacts1 = whiskContacts1;

clear whiskSig1; % filtWhiskSig1;


%% and find first BOT whisker contacts in each trial

afterStim = 50; % samples to wait after stim trig to avoid stim artifact

% select out regions during stimulus epoch to look for whisker contacts
stimEpochStart = stimTrig + afterStim; % + sf/20;   % start looking for whisker contacts after motor artifact should have ended
stimEpochEnd = stimEpochStart + 1.7*sf;  % and stop just before the end motor artifact


whiskContactCell1 = {};
firstContactArr1 = [];

whiskContacts1 = [];
firstContactArrAbsT1 = [];

for k = 1:length(stimTrig)   % so for each stimulus trigger in the corresponding stimulus epoch
    
    % select out epoch of whisker signal (based upon trial triggers)
    whiskTrial = filtWhiskSig1(stimEpochStart(k):stimEpochEnd(k));  % isolate whisker signal for this stimulus trial (either type)
    % NOTE that this might fall outside of the whisker read epoch so
    % may generate error
    
    %whiskTrial = filtwhiskSig1;
    
    % detect peaks (whisker touches)
    %timeoutMs = 10;  % how many ms minimum between whisk touches
    %timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
    %stdThresh = 0.4;  % stdev threshold for whisker touch detection
    
    whiskContactTrial1 = LocalMinima(-whiskTrial, timeoutSamp, -stdThresh1); 
    
    %whiskContactTrial = LocalMinima(-whiskTrial, timeoutSamp, -(stdThresh*stdWhisk));  % detects peaks using LocalMinima (Buzsaki/Harris(kmf))
    %whiskContactTrial = whiskContactTrial + stimEpochStart(k);  % adjust indices to make relative to whole recording (not just this trial)
    %NOTE: that this is slightly misaligned but shouldn't matter much
    %NOTE: now not adjusting to absolute time because trying to make
    %single-trial cells for using with linescan frames from VSD imaging
    
    
    % now concatenate the latest whisker contacts with the previous
    if ~isempty(whiskContactTrial1)
        whiskContactTrial1 = whiskContactTrial1 + afterStim;  % now adjusted for time since start of this trial
        whiskContactCell1{k} = whiskContactTrial1;   % and put in cell array (since can be diff num of touches in each trial)
        whiskContactTrialAdj1 = whiskContactTrial1+stimTrig(k);   % this gives absolute time of touches (vs. whole session) in this trial
        whiskContacts1 = vertcat(whiskContacts1, whiskContactTrialAdj1); % and concatenate with all other trials
        
        firstContact1 = whiskContactTrial1(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr1(k) = firstContact1;  % array of first contact times (relative to trial)
        firstContactArrAbsT1(k) = firstContact1 + stimTrig(k);  % array of first contact times (absolute, vs. session)
    else
        whiskContactCell1{k} = 0;  % don't know if I need this
        firstContactArr1(k) = 0;
        firstContactArrAbsT1(k) = 0;
        
    end
    
end

firstContactTimes1 = firstContactArrAbsT1(firstContactArrAbsT1 ~= 0);

eventStruc.firstContactArrAbsT1 =  firstContactArrAbsT1;
eventStruc.firstContactTimes1 = firstContactTimes1;

% now find first contact times for correct and incorrect rewarded trials
corrFirstContactTimes1 = firstContactArrAbsT1(corrRewInd);
incorrFirstContactTimes1 = firstContactArrAbsT1(incorrRewInd);
incorrFirstContactTimes1 = incorrFirstContactTimes1(incorrFirstContactTimes ~= 0);

eventStruc.corrFirstContactTimes1 = corrFirstContactTimes1;
eventStruc.incorrFirstContactTimes1 = incorrFirstContactTimes1;


%% now for other whisker signal (BOT, at least as of 071313)

whiskContacts2 = [];

% whiskSig1 = whiskSig1-mean(whiskSig1);

% stdWhisk = std(whiskSig1);

% filter whisker signal

%filtWhiskSig2 = filtfilt(MyFilt1,1,whiskSig2);
filtWhiskSig2 = whiskSig2 - runmean(whiskSig2, 20);  % 071913: now subtracting running mean instead of filtering

%timeoutMs = 10;  % how many ms minimum between whisk touches
%timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh2 = 4*std(filtWhiskSig2);  % stdev threshold for whisker touch detection
    
whiskContacts2 = LocalMinima(-filtWhiskSig2,timeoutSamp, -stdThresh2);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));

eventStruc.whiskContacts2 = whiskContacts2;

clear whiskSig2; % filtWhiskSig2;



%% and find first TOP whisker contacts in each trial

whiskContactCell2 = {};
firstContactArr2 = [];

whiskContacts2 = [];
firstContactArrAbsT2 = [];

for k = 1:length(stimTrig)   % so for each stimulus trigger in the corresponding stimulus epoch

    % select out epoch of whisker signal (based upon trial triggers)
    whiskTrial = filtWhiskSig2(stimEpochStart(k):stimEpochEnd(k));  % isolate whisker signal for this stimulus trial (either type)
    % NOTE that this might fall outside of the whisker read epoch so
    % may generate error
    
    %whiskTrial = filtwhiskSig1;
    
    % detect peaks (whisker touches)
    %timeoutMs = 10;  % how many ms minimum between whisk touches
    %timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
    %stdThresh = 0.4;  % stdev threshold for whisker touch detection
    
    whiskContactTrial2 = LocalMinima(-whiskTrial, timeoutSamp, -stdThresh2); 
    
    %whiskContactTrial = LocalMinima(-whiskTrial, timeoutSamp, -(stdThresh*stdWhisk));  % detects peaks using LocalMinima (Buzsaki/Harris(kmf))
    %whiskContactTrial = whiskContactTrial + stimEpochStart(k);  % adjust indices to make relative to whole recording (not just this trial)
    %NOTE: that this is slightly misaligned but shouldn't matter much
    %NOTE: now not adjusting to absolute time because trying to make
    %single-trial cells for using with linescan frames from VSD imaging
    
    
    % now concatenate the latest whisker contacts with the previous
    if ~isempty(whiskContactTrial2)
        whiskContactTrial2 = whiskContactTrial2 + afterStim;  % now adjusted for time since start of this trial
        whiskContactCell2{k} = whiskContactTrial2;   % and put in cell array (since can be diff num of touches in each trial)
        whiskContactTrialAdj2 = whiskContactTrial2+stimTrig(k);   % this gives absolute time of touches (vs. whole session) in this trial
        whiskContacts2 = vertcat(whiskContacts2, whiskContactTrialAdj2); % and concatenate with all other trials
        
        firstContact2 = whiskContactTrial2(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr2(k) = firstContact2;  % array of first contact times (relative to trial)
        firstContactArrAbsT2(k) = firstContact2 + stimTrig(k);  % array of first contact times (absolute, vs. session)
    else
        whiskContactCell2{k} = 0;  % don't know if I need this
        firstContactArr2(k) = 0;
        firstContactArrAbsT2(k) = 0;
        
    end
    
end

firstContactTimes2 = firstContactArrAbsT2(firstContactArrAbsT2 ~= 0);

eventStruc.firstContactArrAbsT2 =  firstContactArrAbsT2;
eventStruc.firstContactTimes2 = firstContactTimes2;

% now find first contact times for correct and incorrect rewarded trials
corrFirstContactTimes2 = firstContactArrAbsT2(corrRewInd);
incorrFirstContactTimes2 = firstContactArrAbsT2(incorrRewInd);
incorrFirstContactTimes2 = incorrFirstContactTimes2(incorrFirstContactTimes ~= 0);

eventStruc.corrFirstContactTimes2 = corrFirstContactTimes2;
eventStruc.incorrFirstContactTimes2 = incorrFirstContactTimes2;


%% Find licks

if skipSig(6) ~= 0
    dLick = [0 diff(lickSig)];

    % detect lever presses and lifts
    licks = LocalMinima(-dLick, 20, -0.5);

    % NOTE: this method does a pretty good job but might miss a few licks
    % because TOP whisker hits might obscure them (thus absolute thresh might
    % be better)

    eventStruc.licks = licks;
else
    eventStruc.licks = [];
end

clear lickSig dLick;


%% Find frames (NOTE: this detects the ends of respective frames)

% galvoSig = x2(7,:);

frameTimeout = round(1/fps*1000-(200/fps));

frameTrig = LocalMinima(galvoSig, frameTimeout, -0.5);
% Note: this works for 2Hz but need to check for 4Hz, and 
% for diff angle galvo signal

galvoAvMax = mean(galvoSig(frameTrig));
frameTrig = frameTrig(galvoSig(frameTrig)<(galvoAvMax + 0.1));  % this cleans up frame trigger times to prevent mistakes

eventStruc.frameTrig = frameTrig;

clear galvoSig;



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

eventStruc.punTime = punTime;




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















