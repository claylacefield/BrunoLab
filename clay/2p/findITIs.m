function [itiStruc] = findITIs(dendriteBehavStruc, toPlot)

%% USAGE: [itiStruc] = findITIs(dendriteBehavStruc);
% Clay Apr/May 2015
% This script takes a dendriteBehavStruc and detects stim epochs and ITIs
% based upon artifacts in the continuous signal acquisition (e.g. the pun
% signal) during the trial epochs
% For use when finding activity during ITIs vs. trial epochs


%% Load in continuous signal for ITI epoch determination

% find the .bin file basename using .txt file name in dendriteBehavStruc
txtFileName = dendriteBehavStruc.eventStruc.correctRespStruc.name;
basename = txtFileName(1:(strfind(txtFileName, '.txt')-1));

cd ..;

% now load in continuous signals 
x2 = binRead2pSingleName([basename '.bin']);

% extract out signal for determining ITI epochs
startSig = x2(8,:);  % NOTE: now using pun signals because less contam.

maxV = max(startSig);

% and use rewSig if startSig is weird small one
if maxV < 3
    
    startSig = x2(3,:);
    maxV = max(startSig);
end

clear x2;


%% Find voltage distribution for different epochs (lowest V's are ITIs)
rmStart = runmean(startSig, 10);  % smooth out startSig

rmStart = rmStart - runmean(rmStart, 12000);

[counts, centers] = hist(rmStart, 1000);  % find distrib of voltages

% find threshold for hist peaks based upon number of trials
numTrials = length(dendriteBehavStruc.eventStruc.stimTrigTime);
histPkThresh = numTrials*100;  % just scaling thresh # V values by # trials x ms

vStartPks = LocalMinima(-counts, 20, -histPkThresh); % find common voltage hist indices (iti baseline, startTrig val, stim artif val, stim/catch baseline)

% now convert these indices back into voltages
pkV = centers(vStartPks);  % find common voltage val (lower = iti, higher = trials)
% NOTE: only taking the lower value, i.e. not the TTL signal, for shift in
% baseline with stim onset
pkCounts = counts(vStartPks);  % and how common

%[newCounts, newOrder] = sort(pkCounts);  % sort least common (stim artifact) to most common (iti or stim epoch)

%stimArtVal = pkV(newOrder(1));

% actually, going to base everything upon iti indices (the lower voltage
% value peak, i.e. first in list)
itiVal = pkV(1);
% NOTE: pkV(2) will probably be the trial epoch voltage

% find indices of putative iti based upon being close to avg iti voltage
itiInd = find(abs(rmStart-itiVal) < (pkV(2)-pkV(1))/2);

% find iti based upon big gaps between iti indices
itiEndInd = itiInd(find(diff(itiInd)>1000));
% and likewise for iti end
itiBegInd = itiInd(find(diff(itiInd)>1000) + 1);


%% NOW only pick out ITIs during session (i.e. not first or last gaps) and save

% find stim epochs based upon iti's (between stim movements)
itiStruc.stimEpBegInd = itiEndInd +170;
itiStruc.stimEpEndInd = itiBegInd -270;

% and then adjust iti with beginning and ending points
% itiEndInd2 = [itiEndInd length(rmStart)];
% itiBegInd2 = [1 itiBegInd];
% OR just count ITIs between trials (i.e. not initial and final periods)
itiEndInd = itiEndInd(2:end);
itiBegInd = itiBegInd(1:end-1);
itiStruc.itiEndInd = itiEndInd;
itiStruc.itiBegInd = itiBegInd;

%% Plotting (if desired)

%toPlot = 1;

if toPlot == 1
    % plot begin and ends of iti's
    figure; plot(rmStart);
    hold on;
    %plot(t(itiInd), rmStart(itiInd), 'r.');
    t = 1:length(rmStart);
    plot(t(itiEndInd), rmStart(itiEndInd), 'y.');
    plot(t(itiBegInd), rmStart(itiBegInd), 'm.');
    
end

