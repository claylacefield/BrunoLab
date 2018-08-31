function plotWhiskCaPS3()

%x2 = binRead2p(8);

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

% now extract and plot

startSig = x2(1,:);
rewSig = x2(3,:);
t = 1:length(rewSig);

ca = dendriteBehavStruc.frameAvgDf;
frameTrig = dendriteBehavStruc.eventStruc.frameTrig;

angle = -whiskDataStruc.meanAngle(1:end-1);
whFrTimes = whiskDataStruc.frTimes;

ca = (ca - mean(ca))/std(ca);
angle = (angle - mean(angle))/std(angle);

figure; 
plot(startSig, 'c');
hold on;
plot(rewSig, 'g');
plot(whFrTimes, angle);

plot(frameTrig, ca, 'g');