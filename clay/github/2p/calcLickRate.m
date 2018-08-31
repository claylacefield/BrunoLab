function [lickRate] = calcLickRate(dendriteBehavStruc)

% This is a script to calculate the licking rate over time intervals
% corresponding to each 2p frame


frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
lickTime = dendriteBehavStruc.eventStruc.lickTime;

frameInterval = round(mean(diff(frameTrig)));

for binNum = 1:length(frameTrig)
    binLickCount(binNum) = length(find(lickTime>frameTrig(binNum)-frameInterval & lickTime<=frameTrig(binNum)));
end

lickRate = binLickCount;