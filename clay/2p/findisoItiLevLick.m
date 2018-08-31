function [eventStruc] = findisoItiLevLick(eventStruc, itiStruc);


%[itiStruc] = findStimITIind(eventStruc, x2);
itiStartTime = itiStruc.itiBegTimes;
itiEndTime = itiStruc.itiEndTimes;

licks = eventStruc.lickTime;
levPress = eventStruc.levPressTime;
levLift = eventStruc.levLiftTime;
rewTime = eventStruc.rewTime; 
punTime = eventStruc.punTime; 
stimTrig = eventStruc.stimTrigTime;

%% find lick bouts
% consecutive licks in a bout tend to be <150ms apart (but changed to 350
% because sometimes slower licks at end of bouts)

dLicks = diff(licks);
lickBoutStart = licks(find(dLicks>350)+1);
%licks = lickBoutStart;  % now calculate everything based upon lickBouts (not all licks) 021917

%% find all levLift/Press during ITIs
itiLevLift = [];
itiLevPress = [];
itiLick = [];

for stimNum = 1:length(stimTrig)
    try
    itiLevLift = [itiLevLift; levLift(levLift > itiStartTime(stimNum) & levLift < itiEndTime(stimNum))];
    itiLevPress = [itiLevPress; levPress(levPress > itiStartTime(stimNum) & levPress < itiEndTime(stimNum))];
    itiLick = [itiLick; lickBoutStart(lickBoutStart > itiStartTime(stimNum) & lickBoutStart < itiEndTime(stimNum))];
    catch
    end
end

eventStruc.itiLevLiftTime = itiLevLift;
eventStruc.itiLevPressTime = itiLevPress;
eventStruc.itiLickTime = itiLick;

%% find isolated licks

preEvLockout = 500;
postEvLockout = 2000;

whiskContacts1 = eventStruc.whiskContactTime1;

rewPunStimLevTime = sort([rewTime; punTime; stimTrig; levLift; levPress; whiskContacts1]);

isoLickTime = [];

for eventNum = 1:(length(rewPunStimLevTime)-1)
   isoLickTime = [isoLickTime; lickBoutStart(lickBoutStart > (rewPunStimLevTime(eventNum)+preEvLockout) & lickBoutStart < (rewPunStimLevTime(eventNum+1)-postEvLockout))]; 
    
end

try
eventStruc.isoLickTime = isoLickTime;
catch
end

% and isolated lever lifts

rewPunStimLickTime = sort([rewTime; punTime; stimTrig; licks; whiskContacts1]);

isoLevLiftTime = [];

for eventNum = 1:(length(rewPunStimLickTime)-1)
   isoLevLiftTime = [isoLevLiftTime; levLift(levLift > (rewPunStimLickTime(eventNum)+preEvLockout) & levLift < (rewPunStimLickTime(eventNum+1)-postEvLockout))]; 
    
end

try
eventStruc.isoLevLiftTime = isoLevLiftTime;
catch
end

% and isolated lever lifts

% rewPunStimLickTime = sort([rewTime; punTime; stimTrig; licks]);

isoLevPressTime = [];

for eventNum = 1:(length(rewPunStimLickTime)-1)
   isoLevPressTime = [isoLevPressTime; levPress(levPress > (rewPunStimLickTime(eventNum)+preEvLockout) & levPress < (rewPunStimLickTime(eventNum+1)-postEvLockout))]; 
    
end

try
eventStruc.isoLevPressTime = isoLevPressTime;
catch
end