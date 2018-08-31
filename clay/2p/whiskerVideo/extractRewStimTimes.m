function [rewStimAdjTime] = extractRewStimTimes()

[filename pathname] = uigetfile('*.mat', 'Select a "dendriteBehavStruc" file to read');
filepath = [pathname filename];

load(filepath);

stimTrig =  dendriteBehavStruc.eventStruc.stimTrigTime;

rewStimStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;

rewStimTime = stimTrig(rewStimStimInd);

% adjust time because start time is actually a little before 
% stim moves, and I'm establishing time from video based upon
% when rew stim stops moving
rewStimAdjTime = rewStimTime + 320; 