


% This script basically recapitulates the pilot analysis I did on 092415
% with the randRew unit data compiled June 2015 (on R103R112 unit data).


cd('/home/clay/Documents/Data/analysis/Spring2015/randRew/');

% This one is for randRew units (not including reward delay)

load('R103R112_unitRew4DelayStruc2_14-Jun-2015.mat');

unitRandRewPvalCell = unitRew4DelayStruc2.unitRandRewPvalCell;

% find randRew units in each session
numRandRewUnits = cellfun(@(x) sum(length(find(x<=0.05))), unitRandRewPvalCell);

% find total number of units in each session
numGoodUnits = cellfun(@(x) length(x), unitRandRewPvalCell);

percRandRewUnits = numRandRewUnits./numGoodUnits; % percent randRew units per session

% separate sessions for each mouse
R103randRewUnitPerc = percRandRewUnits(1:9);
R112randRewUnitPerc = percRandRewUnits(11:19);


%% Plot

figure; 
plot(R103randRewUnitPerc,'g.');
hold on; 
plot(R112randRewUnitPerc,'.');
title(['R103 (g) and R112 (b) percent randRew units by session ' date]);
xlabel('session');
ylabel('% randRew units');




%% Now randRew and rewTracking (rewDelay) data

load('R103R112_unitRew4DelayStats_15-Jun-2015.mat');

rewEpRateMat = unitRew4DelayStats.rewEpRateMat(:,:,1)*4;
unitRandRewPval = unitRew4DelayStats.unitRandRewPval;
segDiffInd = unitRew4DelayStats.segDiffInd;
rewStimCa = unitRew4DelayStats.rewStimCa;

randRewUnitInd = find(unitRandRewPval <= 0.05);
rewTrackUnitInd = find(segDiffInd <= 1);
bothRewUnitInd = intersect(randRewUnitInd, rewTrackUnitInd);


numSplusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))>1));
numSminusUnits = sum(((rewEpRateMat(:,2)./rewEpRateMat(:,1))<1));

figure; 
hold on;
line([0 0.4], [0 0.4], 'Color', [0.9 0.9 0.9]);
scatter(rewEpRateMat(:,1), rewEpRateMat(:,2), 'MarkerEdgeColor', 'k');
scatter(rewEpRateMat(randRewUnitInd,1), rewEpRateMat(randRewUnitInd,2), 'FaceColor', 'r');
scatter(rewEpRateMat(rewTrackUnitInd,1), rewEpRateMat(rewTrackUnitInd,2), 'FaceColor', 'g');
scatter(rewEpRateMat(bothRewUnitInd,1), rewEpRateMat(bothRewUnitInd,2), 'FaceColor', 'y');
legend('unity line', 'all units', 'randRew units', 'rewTracking units', 'both rew');
title(['R103, R112 reward responsive units ' date]);
xlabel('Go trial rate');
ylabel('pre-trial rate');




