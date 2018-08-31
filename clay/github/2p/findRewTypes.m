function [eventStruc] = findRewTypes(eventStruc, rewSig)

correctRespStruc = eventStruc.correctRespStruc;
stimTrig = eventStruc.stimTrigTime;

sf = 1000;

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

%clear rewSig;

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
    else    % if rewArr>rewTime
        rewArrArdT = correctRespStruc.rewArrArdT;
        xc = xcorr(diff(rewTime), diff(rewArrArdT));
        [val,ind] = max(xc);
        offset = (length(xc)+1)/2-ind; % #stimInd offset bet ardStim and labv
        rewArr = rewArr(offset+1:length(rewTime)+offset);
        correctRespStruc.rewArr = rewArr;
        
    end
    
end

eventStruc.correctRespStruc = correctRespStruc;

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
correctRewStimInd = correctRespStruc.correctRewStimInd;
correctRewLatency = correctRespStruc.correctRewLatency;

corrLatStimTime = stimTrig(correctRewStimInd);
rewTime10 = corrLatStimTime + correctRewLatency';
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
    rewDiff = rewTime1-rewTime10;  % diff between real rew time and expected
    rewInd1 = find(rewDiff < 200);
    rewInd2 = find(rewDiff >= 200 & rewDiff < 400);
    rewInd3 = find(rewDiff >= 400 & rewDiff < 700);
    rewInd4 = find(rewDiff >= 700 & rewDiff < 900);
    rewInd5 = find(rewDiff >= 900);
    
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