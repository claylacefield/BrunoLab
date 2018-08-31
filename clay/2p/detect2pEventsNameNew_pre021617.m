function [eventStruc, varargout] = detect2pEventsNameNew(sessionBasename, numFrames)  %, numFrames)

%%
% This function detects a variety of behavioral events recorded along with
% 2p imaging of dendrites
%
% NOTE: 150518- now using subfunctions for event identification and also
% establishing fps from num frames and galvoSig



% Currently, the signals recorded on the NI USB board are:
% 1: stimulus triggers
% 2: lever press
% 3: reward
% 4: BOT whisker signal (071313: or is it now TOP
% 5: TOP whisker signal                       BOT???)
% 6: lick signal
% 7: galvo signal
% 8: pun signal (sometimes don't use this if channel used by TTL, etc.)

% Changes Jan. 2013
% - changed the methods for event detection, finding the local maximum 
%   of the derivative of channels step pulse signals




%% Set various parameters

% nChannels = dataFileArray{rowInd, 7};
nChannels = 8;
% sf = dataFileArray{rowInd, 7};
sf = 1000;
% skipSig = dataFileArray{rowInd, 6};
% fps = dataFileArray{rowInd, 6};

Nyquist = sf/2;

% find mouse session name

%sessionBasename = filename(1:(strfind(filename, '.bin')-1));

binFilename = [sessionBasename '.bin'];

% sessionBasename = sessBasename;

%% Run behavioral analysis (e.g. correct and incorrect trials)

% [correctRespStruc] = correctResp2pBatch(dataFileArray, rowInd);
% [correctRespStruc] = correctResp2p();

[correctRespStruc] = correctResp2pSingleName(sessionBasename);

eventStruc.correctRespStruc = correctRespStruc; 


%% Extract behavioral data
% (from vsdBehavAnalysis.m)

% use UI to pick TXT behavioral data file and analyze
%[correctRespStruc] = correctResp2p();

stimType = correctRespStruc.stimTypeArr;
stimTimeArr = correctRespStruc.stimTimeArr;
corrRespArr = correctRespStruc.corrRespArr;
incorrLevPressLatency = correctRespStruc.incorrLevPressLatency;

eventStruc.stimType = stimType;

% find indices of diff trial types
rewStimStimInd = find(stimType == 1);
unrewStimStimInd = find(stimType == 2);

% correct resp
typeXresp = stimType.*corrRespArr;  % creates array with stim type if correct and 0 if incorrect
corrRewInd = find(typeXresp == 1); % then find the indices of correct rewarded trials
corrUnrewInd = find(typeXresp == 2);    % and incorrect

% incorr resp
typeXincorr = stimType-typeXresp;   % and reverse for incorrect responses
incorrRewInd = find(typeXincorr == 1); 
incorrUnrewInd = find(typeXincorr == 2);

eventStruc.rewStimStimInd = rewStimStimInd;
eventStruc.unrewStimStimInd = unrewStimStimInd;
% eventStruc.corrRewInd = corrRewInd;
% eventStruc.corrUnrewInd = corrUnrewInd;
% eventStruc.incorrRewInd = incorrRewInd;
% eventStruc.incorrUnrewInd = incorrUnrewInd;

eventStruc.correctStimInd = correctRespStruc.correctStimInd;
eventStruc.incorrectStimInd = correctRespStruc.incorrectStimInd;

eventStruc.rewStimInd = correctRespStruc.rewStimInd;
eventStruc.punStimInd = correctRespStruc.punStimInd;
% eventStruc.unrewStimInd = correctRespStruc.unrewStimInd;
eventStruc.correctRewStimInd = correctRespStruc.correctRewStimInd;
eventStruc.correctUnrewStimInd = correctRespStruc.correctUnrewStimInd;
eventStruc.incorrectRewStimInd = correctRespStruc.incorrectRewStimInd;
eventStruc.incorrectUnrewStimInd = correctRespStruc.incorrectUnrewStimInd;

eventStruc.rewArr = correctRespStruc.rewArr;
eventStruc.punArr = correctRespStruc.punArr;


%% Read in LabView signals (select .bin file with GUI)

x2 = binRead2pSingleName(binFilename);
% x2 = binRead2pBatch(dataFileArray, rowInd);
% x2 = binRead2p(nChannels);

% if skipSig ~= 0
%     x2(skipSig) = 0; % this is to zero any signals for a day that might be bad
% end

stim = x2(1,:);
levSig = x2(2,:);
rewSig = x2(3,:);
% whiskSig1 = x2(4,:);  % NOTE 101313: BOT=4 pre April 2013, then BOT =5
% whiskSig2 = x2(5,:);
lickSig = x2(6,:);
galvoSig = x2(7,:);

if nChannels == 8
    punSig = x2(8,:);
end


% after this, whisk1 = BOT, whisk2 = TOP
% if dataFileArray{rowInd,14}==4
%     whiskSig1 = x2(4,:);
%     whiskSig2 = x2(5,:);
% else
    whiskSig1 = x2(5,:);
    whiskSig2 = x2(4,:);
% end

%clear x2;


%% Find frames (signal #7;   NOTE: this detects the ends of respective frames)

frameTrig = findFrameTrig(galvoSig, numFrames); %, numFrames);
eventStruc.frameTrig = frameTrig;

clear galvoSig;


%% Find stimulus triggers (signal #1)
% NOTE: changed method a bit 042414 because some signals small

 stim(1:100) = 0;

 dStim = runmean(stim, 10);
 %dStim = diff(stim2);
 dStim = [0 dStim];
 stdDstim = std(dStim);
 
stimTrigThresh =  4*stdDstim; % 0.2;  %

% find beginning of start trigger step pulse (as large pos slope)
stimTrig = LocalMinima(-dStim, sf, -stimTrigThresh);


% 013116 adjust if some events cut off
if length(stimTimeArr) ~= length(stimTrig)
    if abs(length(stimTimeArr)-length(stimTrig)) < 3
    [val, ind] = max(xcorr(stimTrig, stimTimeArr));
    shift = length(stimTimeArr)-ind;
    stimTrig = [zeros(shift); stimTrig];
    disp('Adjusting stimTrig because one might have gotten cut off at beginning');
    else
        stimTrig = extractStartTrigs(x2);
        
        disp('StartSig probably weird so extracting from punSig');
    
    end
end


% 051914: put this in because new above method for stimTrig detection based
% upon small signals sometimes doesn't work well for big signals when motor
% problems abort trial early 

numIter = 0;
while length(stimType) ~= length(stimTrig) && numIter < 20
    if length(stimType) > length(stimTrig)
        disp('ERROR in stimTrig detection, decreasing thresh');
        stimTrigThresh =  stimTrigThresh - 0.1*stdDstim;
        stimTrig = LocalMinima(-dStim, 2*sf, -stimTrigThresh); 
        numIter = numIter + 1;
    elseif length(stimType) < length(stimTrig)
        disp('ERROR in stimTrig detection, increasing thresh');
        stimTrigThresh =  stimTrigThresh + 0.1*stdDstim;
        stimTrig = LocalMinima(-dStim, 2*sf, -stimTrigThresh);
        numIter = numIter + 1;
    end
end

if length(stimType) ~= length(stimTrig)
    disp('ERROR in stimTrig, WARNING: truncating');
    stimTrig = stimTrig(1:length(stimType));
end

eventStruc.stimTrigTime = stimTrig;

clear stim dStim;

% find approx start and end times of ITIs
itiStartTime = stimTrig - 1000;
itiEndTime = stimTrig - 100;

%% Find lever presses and lever lifts (signal #2)

% filter lever signal (to get rid of stim artifacts, etc.)
% MyFilt2=fir1(100,50/Nyquist);
% filtLevSig = filtfilt(MyFilt2,1,levSig);

% take derivative
%dFiltLev = [0 diff(filtLevSig)];
dLevSig = [0 diff(levSig)];

% detect lever presses and lifts
levPress = LocalMinima(-dLevSig, sf/100, -1.5);  % LocalMinima(-dFiltLev, 10, -0.2);
levLift = LocalMinima(dLevSig, sf/100, -1.5);

eventStruc.levPressTime = levPress;
eventStruc.levLiftTime = levLift;

clear levSig dLevSig; %filtLevSig;

%% Find rewards (signal #3)

dRew = runmean(rewSig, 10);
 %dStim = diff(stim2);
 dRew = [0 dRew];
 stdDrew = std(dRew);
 
rewThresh =  4*stdDrew; % 0.2;  %


%dRew = [0 diff(rewSig)];

% detect reward triggers
rewTime = LocalMinima(-dRew, sf/4, -rewThresh); % -2); % LocalMinima(-dRew, 100, -0.2);

% %initDelay = min([500 correctRespStruc.initDelay]);
% initDelay = 500;
% rewTime = rewTime(rewTime > initDelay); % 042914 to trim out occasional initial rew with lick scripts

% eventStruc.rewTime = rewTime;

clear rewSig;

% and also find times of particular types of rewards (e.g. tone/sol skip)
rewArr = correctRespStruc.rewArr;

%if length(rewArr)~=length(rewTime)
    if length(rewArr) < length(rewTime)
        rewTime = LocalMinima(-dRew, sf/2, -rewThresh);
    end
%end

%initDelay = min([500 correctRespStruc.initDelay]);
initDelay = 500;
rewTime = rewTime(rewTime > initDelay); % 042914 to trim out occasional initial rew with lick scripts


if length(rewArr)~=length(rewTime)
    disp('wrong number reward events');
    disp(['length(rewArr) = ' num2str(length(rewArr))]);
    disp(['length(rewTime) = ' num2str(length(rewTime))]);
    
    if length(rewArr) < length(rewTime)
        rewTime = rewTime(1:length(rewArr));
        disp('truncating rewTime to rewArr length');
    end
    
end

eventStruc.rewTime = rewTime;

rewInd1 = find(rewArr == 1);
rewInd2 = find(rewArr == 2);
rewInd3 = find(rewArr == 3);
rewInd4 = find(rewArr == 4);
rewTime1 = rewTime(rewInd1);    % time of normal rewards
rewTime2 = rewTime(rewInd2);     % rewTone skip rewards
rewTime3 = rewTime(rewInd3);     % normal punRew switch rewards
rewTime4 = rewTime(rewInd4);     % random rewards

eventStruc.rewTime1 = rewTime1;    % time of normal rewards
eventStruc.rewTime2 = rewTime2;     % rewTone skip rewards
eventStruc.rewTime3 = rewTime3;     % normal punRew switch rewards
eventStruc.rewTime4 = rewTime4;     % random rewards


% now have to calculate rewSolSkip times ("rew 5")
rewSolSkipStimInd = correctRespStruc.rewSolSkipStimInd;
rewSolSkipLatency = correctRespStruc.rewSolSkipLatency;

try  % NOTE 101313: this is occasionally malfunctioning do try/catch for now
rewSolSkipStimTime = stimTrig(rewSolSkipStimInd);
rewSolSkipTime = rewSolSkipStimTime + rewSolSkipLatency';
eventStruc.rewTime5 = rewSolSkipTime;
catch
    eventStruc.rewTime5 = [];
end

% now have to calculate rewToneSolSkip times ("rew 6")
rewToneSolSkipStimInd = correctRespStruc.rewToneSolSkipStimInd;
rewToneSolSkipLatency = correctRespStruc.rewToneSolSkipLatency;

rewToneSolSkipStimTime = stimTrig(rewToneSolSkipStimInd);
rewToneSolSkipTime = rewToneSolSkipStimTime' + rewToneSolSkipLatency;
eventStruc.rewTime6 = rewToneSolSkipTime;

% punRew switch tone skip ("rew 7")
rewInd7 = find(rewArr == 7);
eventStruc.rewTime7 = rewTime(rewInd7);

% now have to calculate punRewSolSkip times ("rew 8")
punRewSolSkipStimInd = correctRespStruc.punRewSolSkipStimInd;
punRewSolSkipLatency = correctRespStruc.punRewSolSkipLatency;

punRewSolSkipStimTime = stimTrig(punRewSolSkipStimInd);
punRewSolSkipTime = punRewSolSkipStimTime + punRewSolSkipLatency;
eventStruc.rewTime8 = punRewSolSkipTime;

% now have to calculate punRewToneSolSkip times ("rew 9")
punRewToneSolSkipStimInd = correctRespStruc.punRewToneSolSkipStimInd;
punRewToneSolSkipLatency = correctRespStruc.punRewToneSolSkipLatency;

punRewToneSolSkipStimTime = stimTrig(punRewToneSolSkipStimInd);
punRewToneSolSkipTime = punRewToneSolSkipStimTime + punRewToneSolSkipLatency;
eventStruc.rewTime9 = punRewToneSolSkipTime;

% now have to calculate normal reward times based upon arduino time ("rew 10")
corrLatStimInd = correctRespStruc.corrLatStimInd;
corrLevPressLatency = correctRespStruc.corrLevPressLatency;

corrLatStimTime = stimTrig(corrLatStimInd);
rewTime10 = corrLatStimTime + corrLevPressLatency';
eventStruc.rewTime10 = rewTime10;


% for new event types (e.g. exp rew) 042914
rewInd11 = find(rewArr == 11);
rewTime11 = rewTime(rewInd11);    % time of normal exp rewards
eventStruc.rewTime11 = rewTime11; 

rewInd12 = find(rewArr == 12);
rewTime12 = rewTime(rewInd12);    % time of start rewards
eventStruc.rewTime12 = rewTime12; 

% and for diff rew delays
try
rewDiff = rewTime1-rewTime10;
rewInd1 = find(rewDiff < 250);
rewInd2 = find(rewDiff >= 250 & rewDiff < 500);
rewInd3 = find(rewDiff >= 500 & rewDiff < 750);
rewInd4 = find(rewDiff >= 750 & rewDiff < 950);
rewInd5 = find(rewDiff >= 950);

rewDelay1Time = rewTime1(rewInd1);
rewDelay2Time = rewTime1(rewInd2);
rewDelay3Time = rewTime1(rewInd3);
rewDelay4Time = rewTime1(rewInd4);
rewDelay5Time = rewTime1(rewInd5);

eventStruc.rewDelay1Time = rewDelay1Time;
eventStruc.rewDelay2Time = rewDelay2Time;
eventStruc.rewDelay3Time = rewDelay3Time;
eventStruc.rewDelay4Time = rewDelay4Time;
eventStruc.rewDelay5Time = rewDelay5Time;
catch
    disp('Problem with rewDelay avgs');
end


%% Find whisker contacts (BOT stim)

% whiskSig1 = whiskSig1-mean(whiskSig1);

% stdWhisk = std(whiskSig1);

% filter whisker signal
%MyFilt1=fir1(100,[10 200]/Nyquist);  % [10 200]
%filtWhiskSig1 = filtfilt(MyFilt1,1,whiskSig1);

filtWhiskSig1 = whiskSig1 - runmean(whiskSig1, 20);  % 071913: now subtracting running mean instead of filtering

timeoutMs = 10;  % how many ms minimum between whisk touches
timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh1 = 4*std(filtWhiskSig1)+0.4;  % stdev threshold for whisker touch detection
    
whiskContacts1 = LocalMinima(-filtWhiskSig1, timeoutSamp, -stdThresh1);  %  (-whiskSig1, timeoutSamp, -(stdThresh*stdWhisk));

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

afterStim = 300; % samples to wait after stim trig to avoid stim artifact

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


%% Find licks (signal #6)  NOTE: missing these in some sessions
% ALSO NOTE: lick signals may fall outside of frame epochs


% if skipSig(6) ~= 0
    dLick = [0 diff(lickSig)];

    % detect lever presses and lifts
    licks = LocalMinima(-dLick, 100, -0.5);

    % NOTE: this method does a pretty good job but might miss a few licks
    % because TOP whisker hits might obscure them (thus absolute thresh might
    % be better)

    eventStruc.lickTime = licks;
% else
%     eventStruc.lickTime = [];
% end

clear lickSig dLick;




%% Punishment times (signal #8;  NOTE: this may not exist for earliest recordings)
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

punArr = correctRespStruc.punArr;
punInd1 = find(punArr == 1);
punInd2 = find(punArr == 2);
punInd3 = find(punArr == 3);
punInd4 = find(punArr == 4);
punTime1 = punTime(punInd1);
eventStruc.punTime1 = punTime1; % normal pun
eventStruc.punTime2 = punTime(punInd2);     % rewPun switch
eventStruc.punTime3 = punTime(punInd3);     % pun tone skip
eventStruc.punTime4 = punTime(punInd4);     % rewPun switch tone skip

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


%% now ITI calculations

itiLevLift = [];
itiLick = [];

for stimNum = 1:length(stimTrig)
    itiLevLift = [itiLevLift; levLift(levLift > itiStartTime(stimNum) & levLift < itiEndTime(stimNum))];
    itiLick = [itiLick; licks(licks > itiStartTime(stimNum) & licks < itiEndTime(stimNum))];
end

eventStruc.itiLevLiftTime = itiLevLift;
eventStruc.itiLickTime = itiLick;

% isolated licks
rewPunStimLevTime = sort([rewTime; punTime; stimTrig; levLift; levPress; whiskContacts1]);

isoLickTime = [];

for eventNum = 1:(length(rewPunStimLevTime)-1)
   isoLickTime = [isoLickTime; licks(licks > (rewPunStimLevTime(eventNum)+2000) & licks < (rewPunStimLevTime(eventNum+1)-2000))]; 
    
end

try
eventStruc.isoLickTime = isoLickTime;
catch
end

% and isolated lever lifts

rewPunStimLickTime = sort([rewTime; punTime; stimTrig; licks; whiskContacts1]);

isoLevLiftTime = [];

for eventNum = 1:(length(rewPunStimLickTime)-1)
   isoLevLiftTime = [isoLevLiftTime; levLift(levLift > (rewPunStimLickTime(eventNum)+2000) & levLift < (rewPunStimLickTime(eventNum+1)-2000))]; 
    
end

try
eventStruc.isoLevLiftTime = isoLevLiftTime;
catch
end

% and isolated lever lifts

% rewPunStimLickTime = sort([rewTime; punTime; stimTrig; licks]);

isoLevPressTime = [];

for eventNum = 1:(length(rewPunStimLickTime)-1)
   isoLevPressTime = [isoLevPressTime; levPress(levPress > (rewPunStimLickTime(eventNum)+2000) & levPress < (rewPunStimLickTime(eventNum+1)-2000))]; 
    
end

try
eventStruc.isoLevPressTime = isoLevPressTime;
catch
end

%% 122513 events based upon performance

try

maxStimTrig = max(stimTrig);
binMin = 3;     % size of time bin for performance measure, in min
binSize = binMin*60*1000;  % size of bins to computer avg performance, in ms
corrRespArr = correctRespStruc.corrRespArr;

% find performance per bin
for perfBins = 1:(ceil(maxStimTrig/binSize))   % for all bins
    stimIndBin = find((stimTrig >= (binSize*(perfBins-1))) & (stimTrig <= (binSize*perfBins))); % find stim triggers in this bin
    corrRespBin = corrRespArr(stimIndBin);  % find the corresponding responses for those trials (correct = 1)
    percCorrBin(perfBins) = sum(corrRespBin)/length(corrRespBin); % and calculate the percent correct for this bin
end

% this part isolates bins with good/med/bad performance
goodPerfPerc = 0.7; % = 0.75; % changed 072214
badPerfPerc = 0.6; % = 0.65;

% find bins with good/bad performance
goodPerfBins = find(percCorrBin >= goodPerfPerc);
medPerfBins = find(percCorrBin > badPerfPerc & percCorrBin < goodPerfPerc);
badPerfBins = find(percCorrBin <= badPerfPerc);

goodRew1Times = [];
medRew1Times = [];
badRew1Times = [];
goodPun1Times = [];
medPun1Times = [];
badPun1Times = [];

% and then find the rew1 times during those good/bad timebins
for goodBin = 1:length(goodPerfBins)
    goodRew1Times = [goodRew1Times; rewTime1(rewTime1 >= (goodPerfBins(goodBin)-1)*binSize & rewTime1 < goodPerfBins(goodBin)*binSize)];
    goodPun1Times = [goodPun1Times; punTime1(punTime1 >= (goodPerfBins(goodBin)-1)*binSize & punTime1 < goodPerfBins(goodBin)*binSize)];
    
end

for medBin = 1:length(medPerfBins)
    medRew1Times = [medRew1Times; rewTime1(rewTime1 >= (medPerfBins(medBin)-1)*binSize & rewTime1 < medPerfBins(medBin)*binSize)];
    medPun1Times = [medPun1Times; punTime1(punTime1 >= (medPerfBins(medBin)-1)*binSize & punTime1 < medPerfBins(medBin)*binSize)];
end

for badBin = 1:length(badPerfBins)
    badRew1Times = [badRew1Times; rewTime1(rewTime1 >= (badPerfBins(badBin)-1)*binSize & rewTime1 < badPerfBins(badBin)*binSize)];
    badPun1Times = [badPun1Times; punTime1(punTime1 >= (badPerfBins(badBin)-1)*binSize & punTime1 < badPerfBins(badBin)*binSize)];
end


eventStruc.goodRew1Times = goodRew1Times;
eventStruc.medRew1Times = medRew1Times;
eventStruc.badRew1Times = badRew1Times;
eventStruc.goodPun1Times = goodPun1Times;
eventStruc.medPun1Times = medPun1Times;
eventStruc.badPun1Times = badPun1Times;
catch
disp('Cannot compute performance-based measures');    
end

% now compute early vs. late Ca signals
try
earlyRew1Times = rewTime1(rewTime1 >= 0 & rewTime1 < 2*binSize);
earlyPun1Times = punTime1(punTime1 >= 0 & punTime1 < 2*binSize);
lateRew1Times = rewTime1(rewTime1 >= (ceil(maxStimTrig/binSize)-1)*binSize & rewTime1 < ceil(maxStimTrig/binSize)*binSize);
latePun1Times = punTime1(punTime1 >= (ceil(maxStimTrig/binSize)-1)*binSize & punTime1 < ceil(maxStimTrig/binSize)*binSize);

eventStruc.earlyRew1Times = earlyRew1Times;
eventStruc.earlyPun1Times = earlyPun1Times;
eventStruc.lateRew1Times = lateRew1Times;
eventStruc.latePun1Times = latePun1Times;

catch
    disp('Cannot process early/late Ca signals');
end

if nargout > 0
    
    varargout{1} = x2;
    
end
