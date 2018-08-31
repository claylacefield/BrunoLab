function [rbp4unitEpochStruc] = wrapRbp4unitAnal();


[rbp4unitEpochStruc] = rbp4unitAnal_020618a();  % _012418a();

rewEpRateMat = []; rewTrackUnits = []; randRewUnits = []; numUnits = 0;
unitIsoLick = []; unitRandRewCa = []; unitRewDelay1 = []; unitRewDelay2 = []; unitRewDelay3 = [];
for i=1:length(rbp4unitEpochStruc)
    try 
        %sessRewTrackUnits = ;
        %sessRandRewUnits = ;
        rewTrackUnits = [rewTrackUnits rbp4unitEpochStruc(i).rew4trackStruc.rewTrackUnits+numUnits];
        randRewUnits = [randRewUnits rbp4unitEpochStruc(i).rew4trackStruc.randRewUnits+numUnits];
        rewEpRateMat = [rewEpRateMat; rbp4unitEpochStruc(i).rew4trackStruc.rewEpRateMat]; 
        
        try
        unitIsoLick = [unitIsoLick squeeze(mean(rbp4unitEpochStruc(i).segStruc.isoLickTimeCa,3))];
        catch
            unitIsoLick = [unitIsoLick NaN(33, length(rbp4unitEpochStruc(i).goodSeg))];
        end
        
        try
        unitRandRewCa = [unitRandRewCa squeeze(mean(rbp4unitEpochStruc(i).segStruc.rewTime4Ca,3))];
        catch
            unitRandRewCa = [unitRandRewCa NaN(33, length(rbp4unitEpochStruc(i).goodSeg))];
        end
        
        try
        unitRewDelay1 = [unitRewDelay1 squeeze(mean(rbp4unitEpochStruc(i).segStruc.rewDelay1TimeCa,3))];
        catch
            unitRewDelay1 = [unitRewDelay1 NaN(33, length(rbp4unitEpochStruc(i).goodSeg))];
        end
        
        try
        unitRewDelay2 = [unitRewDelay2 squeeze(mean(rbp4unitEpochStruc(i).segStruc.rewDelay2TimeCa,3))];
        catch
            unitRewDelay2 = [unitRewDelay2 NaN(33, length(rbp4unitEpochStruc(i).goodSeg))];
        end
        
        try
        unitRewDelay3 = [unitRewDelay3 squeeze(mean(rbp4unitEpochStruc(i).segStruc.rewDelay3TimeCa,3))];
        catch
            unitRewDelay3 = [unitRewDelay3 NaN(33, length(rbp4unitEpochStruc(i).goodSeg))];
        end
        
        numUnits = numUnits + length(rbp4unitEpochStruc(i).goodSeg);
    catch
    end
end

%% Plotting 

% epoch randRewTrack scatter
figure; 
scatterUnitEpochRew4Del(rewEpRateMat, randRewUnits, rewTrackUnits);


% ca avg
neither = setxor(1:numUnits, [randRewUnits rewTrackUnits]);

try
figure; 
plotMeanSEM(unitIsoLick(:,neither), 'b'); % unitIsoLick, 'b'); 
hold on; 
plotMeanSEM(unitIsoLick(:,randRewUnits), 'g'); 
plotMeanSEM(unitIsoLick(:,rewTrackUnits), 'r');
legend('non-rew units', 'randRewUnits', 'rewTrackUnits');
title('isoLickCa');
catch
end

try
figure; 
plotMeanSEM(unitRandRewCa(:,neither), 'b'); %unitRandRewCa, 'b'); 
hold on; 
plotMeanSEM(unitRandRewCa(:,randRewUnits), 'g'); 
plotMeanSEM(unitRandRewCa(:,rewTrackUnits), 'r');
legend('non-rew units', 'randRewUnits', 'rewTrackUnits');

title('unitRandRewCa');
catch
end

try
figure; 
plotMeanSEM(unitRewDelay1(:,rewTrackUnits), 'b'); %unitRandRewCa, 'b'); 
hold on; 
plotMeanSEM(unitRewDelay2(:,rewTrackUnits), 'g'); 
plotMeanSEM(unitRewDelay3(:,rewTrackUnits), 'r');
legend('rewDelay1', 'rewDelay2', 'rewDelay3');

title('rewTrack unit unitRewDelayCa');
catch
end