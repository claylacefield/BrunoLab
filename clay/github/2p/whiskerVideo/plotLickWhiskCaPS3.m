function plotLickWhiskCaPS3()


%% Load in all necessary structures in session directory
sessionDir = dir;

sessionDirNames = {sessionDir.name};

whiskDataStrucName = sessionDir(find(cellfun(@length, strfind(sessionDirNames, 'whiskDataStruc')))).name;
load(whiskDataStrucName);

sessionName = whiskDataStrucName(1:14);

dbsInd = find(cellfun(@length, strfind(sessionDirNames, 'dendriteBehavStruc')));
dbsDatenums = [sessionDir(dbsInd).datenum];
[lsaMax, lastInd] = max(dbsDatenums);
latestDbsInd = dbsInd(lastInd);
load(sessionDir(latestDbsInd).name);   

binFilename = sessionDir(find(cellfun(@length, strfind(sessionDirNames, '.bin')))).name;
x2 = binRead2pSingleName(binFilename);

filename = dendriteBehavStruc.filename;

%%

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
frameAvgDf = dendriteBehavStruc.frameAvgDf;

whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies

frTimes = whiskDataStruc.frTimes;

rewSig = x2(3,:);
rewTimes = dendriteBehavStruc.eventStruc.rewTime;

lickTimes = dendriteBehavStruc.eventStruc.lickTime;

t = 1:frTimes(end);

% and find epochs
[itiStruc] = findStimITIind(dendriteBehavStruc, x2);
stimEpBegInd = itiStruc.stimEpBegInd;
stimEpEndInd = itiStruc.stimEpEndInd;


%% Plot

figure; hold on; 

% plot gray boxes under trial periods
baseValue = -1;
for i = 1:length(stimEpBegInd)
   area(stimEpBegInd(i):stimEpEndInd(i), ones(stimEpEndInd(i)-stimEpBegInd(i)+1,1), 'BaseValue', baseValue, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'none'); 
end

% plot whisker angle
plot(t(frTimes), (whiskerData-mean(whiskerData))/200);

% plot reward and lick times

for i = 1:length(lickTimes)
line([lickTimes(i) lickTimes(i)], [0.25 0.3], 'Color', 'm', 'LineWidth',1);
end

%plot(rewSig/5, 'r');
for i = 1:length(rewTimes)
line([rewTimes(i) rewTimes(i)], [0.25 0.3], 'Color', 'r', 'LineWidth',2);
end

% plot calcium
plot(t(frameTrig), frameAvgDf, 'g', 'LineWidth',2);
% title(filename);
% legend('whiskerAngle/100', 'rewards', 'calcium'); 







