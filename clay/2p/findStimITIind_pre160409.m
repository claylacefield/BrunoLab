function [itiStruc] = findStimITIind(dendriteBehavStruc, x2)

%% IDENTIFY STIM/ITI EPOCHS
% in their entirety, based upon artifacts in behav signals

% identify epochs based upon behav sig

% NOTE: remember that there are some datasets with weird
% small start signals, so may have to account for this
% if I want to generalize

startSig = x2(8,:);  % NOTE: now using pun signals because less contam.

maxV = max(startSig);

% and use rewSig if startSig is weird small one
if maxV < 3
    
    startSig = x2(3,:);
    maxV = max(startSig);
end

rmStart = runmean(startSig, 10);  % smooth out startSig

[counts, centers] = hist(rmStart, 1000);  % find distrib of voltages

% find threshold for hist peaks based upon number of trials

numTrials = length(dendriteBehavStruc.eventStruc.stimTrigTime);
histPkThresh = numTrials*200;

vStartPks = LocalMinima(-counts, 10, -histPkThresh); % find common voltages (iti baseline, startTrig val, stim artif val, stim/catch baseline)

pkV = centers(vStartPks);  % find common voltage val (lower = iti, higher = trials)
% NOTE: only taking the lower vale, i.e. not the TTL signal, for shift in
% baseline with stim onset
pkCounts = counts(vStartPks);  % and how common

[newCounts, newOrder] = sort(pkCounts);  % sort least common (stim artifact) to most common (iti or stim epoch)

%stimArtVal = pkV(newOrder(1));

% actually, going to base everything upon iti indices
itiVal = pkV(1);

% find indices of putative iti based upon being close to low voltage peak
itiInd = find(abs(rmStart-itiVal) < (pkV(2)-pkV(1))/2);

% plot begin and ends of iti's
%figure; plot(rmStart);
%hold on;
%plot(t(itiInd), rmStart(itiInd), 'r.');

% find iti based upon big gaps between iti indices
itiEndInd = itiInd(find(diff(itiInd)>1000));
itiStruc.itiEndInd = itiEndInd;
t = 1:length(rmStart);
%plot(t(itiEndInd), rmStart(itiEndInd), 'y.');

% and likewise for iti end
itiBegInd = itiInd(find(diff(itiInd)>1000) + 1);
itiStruc.itiBegInd = itiBegInd;
%plot(t(itiBegInd), rmStart(itiBegInd), 'm.');

% find stim epochs based upon iti's (between stim movements)
itiStruc.stimEpBegInd = itiEndInd +170;
itiStruc.stimEpEndInd = itiBegInd -270;

% and then adjust iti with beginning and ending points
% itiEndInd2 = [itiEndInd length(rmStart)];
% itiBegInd2 = [1 itiBegInd];
% OR just count ITIs between trials (i.e. not initial and final periods)
itiStruc.itiEndInd2 = itiEndInd(2:end);
itiStruc.itiBegInd2 = itiBegInd(1:end-1);