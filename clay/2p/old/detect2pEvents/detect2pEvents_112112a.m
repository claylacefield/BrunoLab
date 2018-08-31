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

% nChannels = 7;
% sf = 1000;

stimTrigThresh = 2;


%% Read in data

[x2] = binRead2p(nChannels);


%% Find stimulus triggers

stim = x2(1,:);

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

%% Find whisker contacts

whiskSig = x2(5,:);

whiskContacts = [];


%% Find frames

galvoSig = x2(7,:);

frameInds = [];









