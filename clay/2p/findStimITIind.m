function [itiStruc, eventStruc] = findStimITIind(eventStruc, varargin)


%% USAGE: [itiStruc, eventStruc] = findStimITIind(eventStruc, x2);

%% NOTE 041017 NOT FINISHED YET

%disp(num2str(nargin));

if nargin == 1
    x2 = binRead2pSession();
else
    x2 = varargin{1};
end

stimTrigTime = eventStruc.stimTrigTime;
numTrials = length(stimTrigTime);


%% process behavioral signal for trial artifacts (to detect trial/ITIs)
startSig = x2(1,:);
punSig = x2(8,:);

dSig = runmean(startSig, 50);
%dSig = runmean(punSig, 50);

%dSig = runmean(diff(dSig),5);

dSig(1:500) = 0;

% trim out bit around actual pun pulses
punInd = threshold(dSig,1,50);
for i = 1:length(punInd)
    dSig(punInd(i)-30:punInd(i)+200) = 0;
end

% now trim unaccounted for spikes
bigInds = LocalMinima(-dSig, 500, -mean(dSig)-std(dSig)); 
for numAbnPks = 1:length(bigInds)
    dSig(bigInds(numAbnPks)-100:bigInds(numAbnPks)+100) = dSig(bigInds(numAbnPks)-300:bigInds(numAbnPks)-100);
end

dSig = runmean(dSig,100);
dSig = runmean(diff(dSig),5);
dSig(1:700) = 0;
%figure; plot(dSig);

stimEpBegTimes = LocalMinima(-dSig, 3100, -(max(dSig)/3));
stimEpEndTimes = LocalMinima(dSig, 3100, (min(dSig)/2));


stimEpBegTimes = stimEpBegTimes + 200;
stimEpEndTimes = stimEpEndTimes - 200;
itiBegTimes = stimEpEndTimes+250;
itiEndTimes = [stimEpBegTimes(2:end); length(punSig)]; itiEndTimes = itiEndTimes-350;

% plotSig = startSig;
% t = 1:length(plotSig);
% figure; plot(plotSig); 
% hold on; plot(t(stimEpBegTimes), plotSig(stimEpBegTimes), 'g*');
% plot(t(stimEpEndTimes), plotSig(stimEpEndTimes), 'r*');
% plot(t(itiBegTimes), plotSig(itiBegTimes), 'c*');
% plot(t(itiEndTimes), plotSig(itiEndTimes), 'm*');

%firstStim = stimTrigTime(1);

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
%         stimEpBegTimes = stimEpBegTimes(offset+1:length(stimTrigTime)+offset);
%         stimEpEndTimes = stimEpEndTimes(offset+1:length(stimTrigTime)+offset);
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

% if nargout == 1
%    varargout = eventStruc; 
% end
