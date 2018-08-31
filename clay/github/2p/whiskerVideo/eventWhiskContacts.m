function [evWhiskContactArr, evWhiskSigArr] = eventWhiskContacts(dendriteBehavStruc, x2, eventName)

% Clay 091616: script to extract whisking for a given event type (for
% comparison with calcium)
% NOTE: this method finds the zero frame times for an event, finds the
% whisking frame time closest to this, then the frames closest to the
% beginning and ending of the calcium epoch. This is agnostic to calcium
% imaging framerate, possible unlike previous methods.

whiskSig = x2(5,:);     % extract IR sensor signal


frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
evFrInds = dendriteBehavStruc.(eventName);  % extract zero frames for these trials
evBegInds = evFrInds-8; % find frame for beginning of calcium epoch (I think this is right)
evEndInds = evFrInds+24;    % then frame for end
evBegTimes = frameTrig(evBegInds);  % and now get the times for the beginning
evEndTimes = frameTrig(evEndInds);  % and the ending time for each event trial

%% IDENTIFY STIM/ITI EPOCHS
% in their entirety, based upon artifacts in behav signals

[itiStruc] = findStimITIind(dendriteBehavStruc, x2);

% itiBegTimes = itiStruc.itiBegTimes;
% itiEndTimes = itiStruc.itiEndTimes;
stimEpBegTimes = itiStruc.stimEpBegTimes;
stimEpEndTimes = itiStruc.stimEpEndTimes;

rewStimStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;


for evNum = 1:length(evFrInds)
    
    % compile whisker detector signal for each trial
     evWhisk = whiskSig(evBegTimes(evNum):evEndTimes(evNum));
%     evWhisk2 = interp1(evBegTimes(evNum):evEndTimes(evNum),evWhisk,linspace(evBegTimes(evNum), evEndTimes(evNum),4000)');
%     evWhiskSigArr(:,evNum) = evWhisk2;
    
    rewStimEpBegTime = stimEpBegTimes(rewStimStimInd(evNum))+100;
    rewStimEpEndTime = stimEpEndTimes(rewStimStimInd(evNum))-100;
    
    a = whiskSig(rewStimEpBegTime:rewStimEpEndTime);
    a2 = runmean(a,4);
    a3 = a2-runmean(a2,200);
    %a3 = a2-mean(a2);
    pk = LocalMinima(-a3,30,-std(a3)); % NOTE this is now on timebase of truncated trial signal
    
    contactsBinMs = zeros(rewStimEpEndTime-rewStimEpBegTime,1);
    contactsBinMs(pk+rewStimEpBegTime) = 1;
    
    figure; subplot(2,1,1); plot(contactsBinMs); xlim([evBegTimes(evNum) evEndTimes(evNum)]); subplot(2,1,2); plot(evWhisk,'g');
    
    evWhiskContactArr = [];
    
end

