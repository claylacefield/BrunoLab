function plotWhiskCaPS3()


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

% filename = dendriteBehavStruc.filename;

%%

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
frameAvgDf = dendriteBehavStruc.frameAvgDf;

whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies

frTimes = whiskDataStruc.frTimes;

rewSig = x2(3,:);

t = 1:frTimes(end);

%% Plot

whiskerData = runmean(whiskerData, 5);
whAdj = (whiskerData-mean(whiskerData))/100;

figure; 
plot(t(frTimes), whAdj);
hold on; 
plot(rewSig/5, 'r');
plot(t(frameTrig), frameAvgDf, 'g');
try
    filename = dendriteBehavStruc.filename;
    title(filename);
catch
end








