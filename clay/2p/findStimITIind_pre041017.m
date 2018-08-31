function [itiStruc, eventStruc] = findStimITIind(eventStruc, x2)

%% IDENTIFY STIM/ITI EPOCHS
% in their entirety, based upon artifacts in behav signals

% identify epochs based upon behav sig

% NOTE: remember that there are some datasets with weird
% small start signals, so may have to account for this
% if I want to generalize

startSig = x2(8,:);  % NOTE: now using pun signals because less contam.
startSig(1:500) = 0;

% maxV = max(startSig);
% 
% % and use rewSig if startSig is weird small one
% if maxV < 3
%     
%     startSig = x2(3,:);
%     maxV = max(startSig);
% end

rmStart = runmean(startSig, 10);  % smooth out startSig

[counts, centers] = hist(rmStart, 1000);  % find distrib of voltages

% find threshold for hist peaks based upon number of trials
stimTrigTime = eventStruc.stimTrigTime;
numTrials = length(stimTrigTime);
histPkThresh = numTrials*200;

vStartPks = LocalMinima(-counts, 10, -histPkThresh); % find common voltages (iti baseline, startTrig val, stim artif val, stim/catch baseline)

pkV = centers(vStartPks);  % find common voltage val (lower = iti, higher = trials)
% NOTE: only taking the lower value, i.e. not the TTL signal, for shift in
% baseline with stim onset
% pkCounts = counts(vStartPks);  % and how common
% 
% [newCounts, newOrder] = sort(pkCounts);  % sort least common (stim artifact) to most common (iti or stim epoch)

%stimArtVal = pkV(newOrder(1));

% actually, going to base everything upon iti indices
itiVal = pkV(1);

% 032217: modify startSig to eliminate artifacts at beginning and end
frameTrig = eventStruc.frameTrig;
rmStart(1:frameTrig(1)) = itiVal;
rmStart(frameTrig(end):end) = itiVal;

% find indices of putative iti based upon being close to low voltage peak
itiInd = find(abs(rmStart-itiVal) < (pkV(2)-pkV(1))/2);

% plot begin and ends of iti's
%figure; plot(rmStart);
%hold on;
%plot(t(itiInd), rmStart(itiInd), 'r.');

% find iti based upon big gaps between iti indices
itiEndTimes = itiInd(find(diff(itiInd)>1000));
%itiStruc.itiEndTimes = itiEndTimes;
%t = 1:length(rmStart);
%plot(t(itiEndTimes), rmStart(itiEndTimes), 'y.');

% and likewise for iti end
itiBegTimes = itiInd(find(diff(itiInd)>1000) + 1);
%itiStruc.itiBegTimes = itiBegTimes;
%plot(t(itiBegTimes), rmStart(itiBegTimes), 'm.');

% find stim epochs based upon iti's (between stim movements)
stimEpBegTimes = itiEndTimes +170;
stimEpEndTimes = itiBegTimes -270;

% and then adjust iti with beginning and ending points
% itiEndTimes2 = [itiEndTimes length(rmStart)];
% itiBegTimes2 = [1 itiBegTimes];
% OR just count ITIs between trials (i.e. not initial and final periods)

% if session ends in ITI
if itiInd(end) == length(rmStart)
%itiBegTimes = itiBegTimes; %
itiEndTimes = [itiEndTimes(2:end) length(rmStart)];
%itiStruc.itiBegTimes = [itiBegTimes(1:end-1) itiStruc.stimEpEndTimes(end) + 270];
else
    stimEpBegTimes = [stimEpBegTimes (itiEndTimes(end) +170)];
    stimEpEndTimes = [stimEpEndTimes length(rmStart)];
end

%% Now fix stim/iti times in case there is a mismatch

% This is for when there is an error in the stim/iti assessment based upon
% artifacts at the beginning and end of the session (e.g. an offset in the
% punSig when the galvoSig starts and stops)
if length(stimTrigTime) ~= length(stimEpBegTimes)
    goodStimLog = stimEpBegTimes >= stimTrigTime(1)-100;
    stimEpBegTimes = stimEpBegTimes(goodStimLog);
    stimEpEndTimes = stimEpEndTimes(goodStimLog);
    itiBegTimes = itiBegTimes(goodStimLog);
    itiEndTimes = itiEndTimes(goodStimLog);
    
end

% This is for when one or more stims are cut off 
% (such as when labview ends while behavior is still going on (or starts
% after behavior has started?))
%stimEpBegTimes = itiStruc.stimEpBegTimes;
if length(stimTrigTime) ~= length(stimEpBegTimes)
    
    
    xc = xcorr(diff(stimTrigTime), diff(stimEpBegTimes));
    [val, ind] = max(xc);
    offset = (length(xc)+1)/2-ind;
    % chop off stims from longer one
    if offset > 0  % if stimTrig > stimEpBeg
        stimTrigTime = stimTrigTime(offset+1:length(stimEpBegTimes)+offset); 
    elseif offset < 0 % if stimTrig < stimEpBeg
        stimEpBegTimes = stimEpBegTimes(offset+1:length(stimTrigTime)+offset);
        stimEpEndTimes = stimEpEndTimes(offset+1:length(stimTrigTime)+offset);
    elseif offset == 0
        if length(stimTrigTime) > length(stimEpBegTimes)
            stimTrigTime = stimTrigTime(1:length(stimEpBegTimes));
        else
            stimEpBegTimes = stimEpBegTimes(1:length(stimTrigTime));
            stimEpEndTimes = stimEpEndTimes(1:length(stimTrigTime));
        end
        
    end
    
    eventStruc.stimTrigTime = stimTrigTime;
end

itiStruc.stimEpBegTimes = stimEpBegTimes;
itiStruc.stimEpEndTimes = stimEpEndTimes;

itiStruc.itiBegTimes = itiBegTimes; %
itiStruc.itiEndTimes = itiEndTimes;
