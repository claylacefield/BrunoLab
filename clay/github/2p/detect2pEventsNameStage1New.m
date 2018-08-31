function [eventStruc] = detect2pEventsNameStage1New(sessBasename, numFrames)

disp(['Processing stage1 data for ' sessBasename]);

%% Set various parameters

%nChannels = dataFileArray{rowInd, 7};
%nChannels = 8;
% sf = dataFileArray{rowInd, 7};
sf = 1000;
% skipSig = dataFileArray{rowInd, 6};
%fps = dataFileArray{rowInd, 6};

%Nyquist = sf/2;

binFilename = [sessBasename '.bin'];

sessionBasename = sessBasename;

%x2 = binRead2pBatch(dataFileArray, rowInd);
x2 = binRead2pSingleName(binFilename);

startSig = x2(1,:);
levSig = x2(2,:);
rewSig = x2(3,:);
lickSig = x2(6,:);
galvoSig = x2(7,:);

%% Find frames (signal #7;   NOTE: this detects the ends of respective frames)


frameTrig = findFrameTrig(galvoSig, numFrames); %, numFrames);
eventStruc.frameTrig = frameTrig;

clear galvoSig;


%% Find stimulus triggers (signal #1)
% NOTE: changed method a bit 042414 because some signals small

startSig(1:50) = 0;

dStim = runmean(startSig, 10);
%dStim = diff(stim2);
dStim = [0 dStim];
%dStim(1:50) = mean(dStim);
stdDstim = std(dStim);

stimTrigThresh =  max([4*stdDstim 0.5]); % 0.2;  %

% find beginning of start trigger step pulse (as large pos slope)
stimTrigTime = LocalMinima(-dStim, sf, -stimTrigThresh);
eventStruc.stimTrigTime = stimTrigTime;

%% Find rewards (signal #3)

dRew = [0 diff(rewSig)];

% detect reward triggers
rewTime = LocalMinima(-dRew, sf, -2); % LocalMinima(-dRew, 100, -0.2);

eventStruc.rewTime = rewTime;

clear rewSig;

[correctRespStruc] = correctResp2pNameStage1(sessionBasename, rewTime);
eventStruc.correctRespStruc = correctRespStruc;
rewArr = correctRespStruc.rewArr;

rewInd1 = find(rewArr == 1);
rewInd2 = find(rewArr == 2);
rewInd3 = find(rewArr == 3);
rewInd4 = find(rewArr == 4);
rewInd11 = find(rewArr == 11);
rewTime1 = rewTime(rewInd1);    % time of normal rewards
rewTime2 = rewTime(rewInd2);     % rewTone skip rewards
rewTime3 = rewTime(rewInd3);     % normal punRew switch rewards
rewTime4 = rewTime(rewInd4);     % random rewards
rewTime11 = rewTime(rewInd11);

eventStruc.rewTime1 = rewTime1;    % time of normal rewards
eventStruc.rewTime2 = rewTime2;     % rewTone skip rewards
eventStruc.rewTime3 = rewTime3;     % normal punRew switch rewards
eventStruc.rewTime4 = rewTime4;     % random rewards
eventStruc.rewTime5 = correctRespStruc.rewTime5;
eventStruc.rewTime6 = correctRespStruc.rewTime6;
eventStruc.rewTime11 = rewTime11;  % exp rew

% and calculate values for times not explicitly defined (???)


% now just pack some stuff to make it easier to do the whisker video
% analysis
stimTypeArr = ones(length(stimTrigTime),1);
eventStruc.correctRespStruc.stimTypeArr = stimTypeArr;

%% Find lever presses and lever lifts (signal #2)

% filter lever signal (to get rid of stim artifacts, etc.)
% MyFilt2=fir1(100,50/Nyquist);
% filtLevSig = filtfilt(MyFilt2,1,levSig);

% take derivative
%dFiltLev = [0 diff(filtLevSig)];
dLevSig = [0 diff(levSig)];

% detect lever presses and lifts
levPress = LocalMinima(-dLevSig, sf/100, -2);  % LocalMinima(-dFiltLev, 10, -0.2);
levLift = LocalMinima(dLevSig, sf/100, -2);

eventStruc.levPressTime = levPress;
eventStruc.levLiftTime = levLift;

clear levSig dLevSig; %filtLevSig;

%% Find licks (signal #6)  NOTE: missing these in some sessions
% ALSO NOTE: lick signals may fall outside of frame epochs


% if skipSig(6) ~= 0
dLick = [0 diff(lickSig)];

% detect lever presses and lifts
licks = LocalMinima(-dLick, 20, -0.5);

% NOTE: this method does a pretty good job but might miss a few licks
% because TOP whisker hits might obscure them (thus absolute thresh might
% be better)

eventStruc.lickTime = licks;
% else
%     eventStruc.lickTime = [];
% end

clear lickSig dLick;

dLicks = diff(licks);
eventStruc.lickBoutTime = licks(find(dLicks>250)+1);
