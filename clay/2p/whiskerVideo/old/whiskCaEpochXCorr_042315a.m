


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
histPkThresh = numTrials*1000;

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
figure; plot(rmStart);
hold on;
%plot(t(itiInd), rmStart(itiInd), 'r.');

% find iti based upon big gaps between iti indices
itiBegInd = itiInd(find(diff(itiInd)>1000));
t = 1:length(rmStart);
plot(t(itiBegInd), rmStart(itiBegInd), 'y.');

% and likewise for iti end
itiEndInd = itiInd(find(diff(itiInd)>1000) + 1);

plot(t(itiEndInd), rmStart(itiEndInd), 'm.');

% find stim epochs based upon iti's (between stim movements)
stimEpBegInd = itiEndInd+200;
stimEpEndInd = itiBegInd-300;

% and then adjust iti with beginning and ending points
itiEndInd2 = [itiEndInd length(rmStart)];
itiBegInd2 = [1 itiBegInd];

rewStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
unrewStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;

% only take whisking var from same period as frameAvgDf
vb = v(find(t2>=frameTrig(1) & t2 <= frameTrig(end)));
t2b = t2(find(t2>=frameTrig(1) & t2 <= frameTrig(end)));

% interp frameAvgDf to whisker imaging frame times
ca2 = interp1(frameTrig, frameAvgDf, t2b);


%% XCORR for these epochs (and plotting)

% now calculate xcorr for all these epochs
for trial = 1:length(itiBegInd2)
    itiCa = ca2(t2b>=itiBegInd2(trial) & t2b<=itiEndInd2(trial)); 
    itiWhisk = vb(t2b>=itiBegInd2(trial) & t2b<=itiEndInd2(trial)); 
    r(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end

figure; 
plot(mean(r,1), 'Color', [1 0 1]);
hold on;

for trial = 1:length(stimEpBegInd)
    itiCa = ca2(t2b>=stimEpBegInd(trial) & t2b<=stimEpEndInd(trial)); 
    itiWhisk = vb(t2b>=stimEpBegInd(trial) & t2b<=stimEpEndInd(trial)); 
    r2(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end

specStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;

%specStimInd = incorrectRewStimInd;

clear r3;

begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);


% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);


for trial = 1:length(begInd)
    itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial)); 
    itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial)); 
    r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end

plot(mean(r3,1), 'Color','b');

figure; 
plot(mean(r,1), 'Color', [1 0 1]);
hold on;
plot(mean(r2,1), 'm');
plot(mean(r3,1), 'y');

% for 2014-09-13-001 I thought the incorrectRewStimInd was wrong
% but it turns out that correctRewStimInd just doesn't include
% sol- (rew5) conditions. Thus doing the below gives you xcorr for 
% rewStim with no rew for this animal

incorrectRewStimInd = rewStimStimInd(find(~ismember(rewStimStimInd, correctRewStimInd)));


rewTime4 = dendriteBehavStruc.eventStruc.rewTime4;


begInd = itiBegInd3; %(specStimInd);
endInd = itiEndInd3; %(specStimInd);


n = 0; clear r3;

for trial = 1:length(begInd)
    
    if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0 
        n = n+1;
        itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
        itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
        r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
    end
end
hold on;
plot(mean(r3,1), 'Color', [0 1 0]);


itiBegInd3 = itiBegInd2 + 500;
itiEndInd3 = itiEndInd2 - 500;


%%%%%%%%%%%%%%%%%%%%%%%%
% RUN THE BELOW TO CREATE GRAPHS LIKE SAVED FOR ITI

figure;
for trial = 1:length(itiBegInd2)
    itiCa = ca2(t2b>=itiBegInd2(trial) & t2b<=itiEndInd2(trial)); 
    itiWhisk = vb(t2b>=itiBegInd2(trial) & t2b<=itiEndInd2(trial)); 
    r(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
plot(mean(r,1), 'Color', [1 0 1]);
begInd = itiBegInd2; %(specStimInd);
endInd = itiEndInd2; %(specStimInd);
n = 0; clear r3;
for trial = 1:length(begInd)
if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))==0
n = n+1;
itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
end
hold on;
plot(mean(r3,1), 'Color', [1 0 0]);
n = 0; clear r3;
for trial = 1:length(begInd)
if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>0
n = n+1;
itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
end
hold on;
plot(mean(r3,1), 'Color', [1 1 0]);
begInd = itiBegInd3; %(specStimInd);
endInd = itiEndInd3; %(specStimInd);
n = 0; clear r3;
for trial = 1:length(begInd)
if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))>=0
n = n+1;
itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
end
hold on;
plot(mean(r3,1), 'Color', [0 1 0]);
specStimInd = dendriteBehavStruc.eventStruc.unrewStimStimInd;
%specStimInd = incorrectRewStimInd;
clear r3;
begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);
% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);
for trial = 1:length(begInd)
itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
plot(mean(r3,1), 'Color','c');
specStimInd = dendriteBehavStruc.eventStruc.rewStimStimInd;
%specStimInd = incorrectRewStimInd;
clear r3;
begInd = stimEpBegInd(specStimInd);
endInd = stimEpEndInd(specStimInd);
% begInd = itiBegInd2(specStimInd);
% endInd = itiEndInd2(specStimInd);
for trial = 1:length(begInd)
itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
plot(mean(r3,1), 'Color','b');

%% 

ind = correctRewStimInd + 1;

begInd = itiBegInd2(ind);
endInd = itiEndInd2(ind);
n = 0; clear r3;
for trial = 1:length(begInd)
if max(rewTime4 > begInd(trial) & rewTime4< endInd(trial))==0
n = n+1;
itiCa = ca2(t2b>=begInd(trial) & t2b<=endInd(trial));
itiWhisk = vb(t2b>=begInd(trial) & t2b<=endInd(trial));
r3(trial, :) = xcorr(itiWhisk, itiCa, 1000);
end
end

plot(mean(r3,1), 'Color',[0.3 0.3 0.3]);

figure;
r4 = xcorr(vb, ca2, 1000, 'coeff');
plot(r4, 'Color', [1 0.5 0.2]);