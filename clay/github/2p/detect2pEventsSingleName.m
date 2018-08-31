function [eventStruc, x2] = detect2pEventsSingleName(sessionBasename, numFrames) %filename, fps)

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

%% Run behavioral analysis (e.g. correct and incorrect trials)

% [correctRespStruc] = correctResp2pBatch(dataFileArray, rowInd);
% [correctRespStruc] = correctResp2p();

[correctRespStruc] = correctResp2pSingleName(sessionBasename);

eventStruc.correctRespStruc = correctRespStruc; 


%% Extract behavioral data
% and find correct/incorrect stim ind

[eventStruc] = findCorrStimInd(eventStruc);
stimType = eventStruc.stimType;


%% Read in LabView signals (select .bin file with GUI)
x2 = binRead2pSingleName([sessionBasename '.bin']);
%x2 = binRead2pSingleName(filename);
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

% galvoSig = x2(7,:);

% frameTimeout = round(1/fps*1000-(200/fps));
% 
% frameTrig = LocalMinima(galvoSig, frameTimeout, -0.5);
% % Note: this works for 2Hz but need to check for 4Hz, and 
% % for diff angle galvo signal
% 
% galvoAvMax = mean(galvoSig(frameTrig));
% frameTrig = frameTrig(galvoSig(frameTrig)<(galvoAvMax + 0.1));  % this cleans up frame trigger times to prevent mistakes


frameTrig = findFrameTrig(galvoSig, numFrames);

eventStruc.frameTrig = frameTrig;

clear galvoSig;


%% Find stimulus triggers (signal #1)
% NOTE: changed method a bit 042414 because some signals small

 dStim = runmean(stim, 10);
 dStim(1:1000) = 0;   % blanking start because of initial artifact 
 %dStim = diff(stim2);
 dStim = [0 dStim];
 stdDstim = std(dStim);
 
stimTrigThresh =  4*stdDstim; % 0.2;  %

% find beginning of start trigger step pulse (as large pos slope)
stimTrig = LocalMinima(-dStim, sf, -stimTrigThresh);

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

[eventStruc] = findRewards(eventStruc, rewSig, sf);

rewTime = eventStruc.rewTime;


%% Find whisker contacts (BOT stim)

[eventStruc] = findWhiskSigContacts(eventStruc, whiskSig1, whiskSig2, sf);


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
rewPunStimLevTime = sort([rewTime; punTime; stimTrig; levLift; levPress]); %  ; whiskContacts1]);

isoLickTime = [];

for eventNum = 1:(length(rewPunStimLevTime)-1)
   isoLickTime = [isoLickTime; licks(licks > (rewPunStimLevTime(eventNum)+2000) & licks < (rewPunStimLevTime(eventNum+1)-2000))]; 
    
end

try
eventStruc.isoLickTime = isoLickTime;
catch
end

% and isolated lever lifts

rewPunStimLickTime = sort([rewTime; punTime; stimTrig; licks]);  % ; whiskContacts1]);

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

[eventStruc] = findPerfBasedMeas(eventStruc);
