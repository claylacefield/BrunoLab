function [eventStruc] = detect2pEvents(nChannels, sf)

%%
% This function detects a variety of behavioral events recorded along with
% 2p imaging of dendrites
%
% Currently, the signals recorded on the NI USB board are:
% 1: stimulus triggers
% 2: lever press
% 3: reward
% 4: TOP whisker signal
% 5: BOT whisker signal
% 6: lick signal
% 7: galvo signal


%% Set various parameters

nChannels = 7;
sf = 1000;



%% Read in data (select .bin file with GUI)

x2 = binRead2p(nChannels);


%% Find stimulus triggers

stim = x2(1,:);

stimTrigThresh = 2;

trigNum = 0;  % increments stimulus trigger events
i = 1;

while i < (length(stim)-1)  % go through this chunk to look for stimulus trigger events
    if (stim(i)>stimTrigThresh)      
        trigNum = trigNum+1;
        stimTrig(trigNum) = i;    % save sample number/index of this event into array
        i = i + sf;  % wait a second before looking for more stim triggers
    else
        i = i + 1;  % if no thresh cross then go to next sample
    end
end

eventStruc.stimTrig = stimTrig;

% clear stim;

%% Find rewards

rewSig = x2(3,:);

rewSigThresh = 2;

rewNum = 0;  % increments stimulus trigger events
i = 1;

while i < (length(rewSig)-1)  % go through this chunk to look for stimulus trigger events
    if (rewSig(i)>rewSigThresh)      
        rewNum = rewNum+1;
        rew(rewNum) = i;    % save sample number/index of this event into array
        i = i + sf;  % wait a second before looking for more stim triggers
    else
        i = i + 1;  % if no thresh cross then go to next sample
    end
end

eventStruc.rewards = rew;

% clear rewSig;

%% Find whisker contacts

whiskSig = x2(4,:);

whiskContacts = [];

whiskSig = whiskSig-mean(whiskSig);

stdWhisk = std(whiskSig);

% filter whisker signal
MyFilt=fir1(100,[10 200]/Nyquist);
filtWhiskSig = filtfilt(MyFilt,1,whiskSig);

timeoutMs = 10;  % how many ms minimum between whisk touches
timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
stdThresh = 0.4;  % stdev threshold for whisker touch detection
    
whiskContacts = LocalMinima(-filtWhiskSig, 50, -0.1);  %  (-whiskSig, timeoutSamp, -(stdThresh*stdWhisk));

eventStruc.whiskContacts = whiskContacts;

% clear whiskSig filtWhiskSig;


%% Find licks

lickSig = x2(6,:);

lickSigThresh = 1.5;

lickNum = 0;  % increments stimulus trigger events
i = 1;

while i < (length(lickSig)-1)  % go through this chunk to look for stimulus trigger events
    if (lickSig(i)>lickSigThresh)      
        lickNum = lickNum+1;
        licks(lickNum) = i;    % save sample number/index of this event into array
        i = i + sf/100;  % wait a second before looking for more stim triggers
    else
        i = i + 1;  % if no thresh cross then go to next sample
    end
end

eventStruc.licks = licks;

% clear lickSig;


%% Find frames (NOTE: this detects the ends of respective frames)

galvoSig = x2(7,:);

frameTrig = LocalMinima(galvoSig, 200, -0.5);
% Note: this works for 2Hz but need to check for 4Hz, and 
% for diff angle galvo signal

eventStruc.frameTrig = frameTrig;

%% Behavioral data
% (from vsdBehavAnalysis.m)

% use UI to pick TXT behavioral data file and analyze
[correctRespStruc] = correctResp2p();

stimType = correctRespStruc.stimTypeArr;
corrRespArr = correctRespStruc.corrRespArr;

% find indices of diff trial types
rewStimInd = find(stimType == 1);
unrewStimInd = find(stimType == 2);

% correct resp
typeXresp = stimType.*corrRespArr;
corrRewInd = find(typeXresp == 1);
corrUnrewInd = find(typeXresp == 2);

% incorr resp
typeXincorr = stimType-typeXresp;
incorrRewInd = find(typeXincorr == 1); 
incorrUnrewInd = find(typeXincorr == 2);













