function [eventStruc, varargout] = detect2pEventsNameNew(sessionBasename, numFrames)  

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


%%%%%%%%%%%%%%%%%


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


%% Find frames (signal #7;   NOTE: this detects the ends of respective frames)

frameTrig = findFrameTrig(galvoSig, numFrames); %, numFrames);

if length(frameTrig) ~= numFrames
    if max(diff(frameTrig))> mean(diff(frameTrig))+4*std(diff(frameTrig))
        disp('Getting frame number discrepancy so aborting');
        clear frameTrig; % this should create error to not process bad sess
    end
end

eventStruc.frameTrig = frameTrig;

clear galvoSig;


%% Find stimulus triggers (signal #1)
[eventStruc] = findStimTrigs(eventStruc, x2);
stimTrig = eventStruc.stimTrigTime;
clear stim;

% this also adjusts stimTrig 
[itiStruc, eventStruc] = findStimITIind(eventStruc, x2);
stimTrig = eventStruc.stimTrigTime;

% re-load this because it might have been changed
correctRespStruc = eventStruc.correctRespStruc; 

%% Extract behavioral data

stimType = correctRespStruc.stimTypeArr;
stimTimeArr = correctRespStruc.stimTimeArr;
corrRespArr = correctRespStruc.corrRespArr;
incorrectUnrewLatency = correctRespStruc.incorrectUnrewLatency;

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
eventStruc.incorrectUnrewStimInd = correctRespStruc.incorrectUnrewStimInd; % < length(stimTrig);



%% Find rewards (signal #3)
disp('Detecting rewards');
[eventStruc] = findRewTypes(eventStruc, rewSig);
rewTime = eventStruc.rewTime;

eventStruc.rewArr = eventStruc.correctRespStruc.rewArr;


%% Find lever presses and lever lifts (signal #2)
disp('Detecting lever presses');
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

%% Whisk contacts
%[itiStruc, eventStruc] = findStimITIind(eventStruc, x2);
disp('Detecting whiskSig contacts');
[eventStruc] = findWhiskSigContacts(eventStruc, whiskSig1, whiskSig2, itiStruc);
stimTrig = eventStruc.stimTrigTime;

%% Find licks (signal #6)  NOTE: missing these in some sessions
disp('Detecting licks');
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
disp('Detecting pun times');
if nChannels == 8
    [eventStruc] = findPun(eventStruc, punSig);
    punTime = eventStruc.punTime;
else
% and calculate the punishment time based upon the arduino time
punTime = stimTrig(incorrectUnrewInd) + incorrectLevPressLatency;
end

%% now ITI calculations
disp('ITI event calculations');
[eventStruc] = findisoItiLevLick(eventStruc, itiStruc);

%% events based upon performance
binMin = 3;
[eventStruc] = findPerfBasedMeas2(eventStruc, binMin);

%% now compute early vs. late Ca signals

rewTime1 = eventStruc.rewTime1;
maxStimTrig = max(stimTrig);

binMin = 3;
binSize = binMin*60*1000;

try
earlyRew1Times = rewTime1(rewTime1 >= 0 & rewTime1 < 1*binSize); % 2*
lateRew1Times = rewTime1(rewTime1 >= (ceil(maxStimTrig/binSize)-1)*binSize & rewTime1 < ceil(maxStimTrig/binSize)*binSize);
eventStruc.earlyRew1Times = earlyRew1Times;
eventStruc.lateRew1Times = lateRew1Times;
catch
    disp('Cannot process early/late rewCa signals');
end

try
earlyPun1Times = punTime1(punTime1 >= 0 & punTime1 < 1*binSize);
latePun1Times = punTime1(punTime1 >= (ceil(maxStimTrig/binSize)-1)*binSize & punTime1 < ceil(maxStimTrig/binSize)*binSize);
eventStruc.earlyPun1Times = earlyPun1Times;
eventStruc.latePun1Times = latePun1Times;
catch
    disp('Cannot process early/late punCa signals');
end

if nargout > 0
    
    varargout{1} = x2;
    
end
