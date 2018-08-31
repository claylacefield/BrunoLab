function [mouseSummCellCompilStruc] = mouseSummRandRewTrack(mouseSummCell, somaDendTag, progNameTag, forWhisk);

%% USAGE: mouseSummRandRewTrack(mouseSummCell, somaDendTag, progNameTag, forWhisk);
% somaDendTag = 's' or 'd'
% progNameTag = e.g. 'RandDelay'

% This script takes a mouseSummCell, compiles all sessions for a variable
% field, and then takes unit subsets

% For now, I'm just going to recapitulate wrapRbp4unitAnal, for
% randRewUnits and rewTrackUnits

rewEpRateMat = []; rewTrackUnits = []; randRewUnits = []; numUnits = 0;
unitIsoLick = []; unitRandRewCa = []; 
unitItiWhiskCa = []; unitWhiskXcorr = []; itiWhiskAngle = [];
for i = 1:size(mouseSummCell,1)
    
    if strcmp(mouseSummCell{i,6}, somaDendTag) && ~isempty(strfind(mouseSummCell{i,7}, progNameTag))
        
        if forWhisk==0 || ~isempty(mouseSummCell{i,21})
            
            try
                rew4trackStruc = mouseSummCell{i,22};
                goodSeg = mouseSummCell{i,14};
                segStruc = mouseSummCell{i,15};
                
                try
                    rewTrackUnits = [rewTrackUnits rew4trackStruc.rewTrackUnits+numUnits];
                catch
                end
                try
                    randRewUnits = [randRewUnits rew4trackStruc.randRewUnits+numUnits];
                catch
                end
                rewEpRateMat = [rewEpRateMat; rew4trackStruc.rewEpRateMat];
                
                try
                    unitIsoLick = [unitIsoLick squeeze(mean(segStruc.isoLickTimeCa,3))];
                catch
                    unitIsoLick = [unitIsoLick NaN(33, length(goodSeg))];
                end
                
                try
                    unitRandRewCa = [unitRandRewCa squeeze(mean(segStruc.rewTime4Ca,3))];
                catch
                    unitRandRewCa = [unitRandRewCa NaN(33, length(goodSeg))];
                end
                
                try
                    unitItiWhiskCa = [unitItiWhiskCa squeeze(mean(mouseSummCell{i,21},2))];
                catch
                    unitItiWhiskCa = [unitItiWhiskCa NaN(33, length(goodSeg))];
                end
                
                try
                    unitWhiskXcorr = [unitWhiskXcorr mouseSummCell{i,17}];
                catch
                    unitWhiskXcorr = [unitWhiskXcorr NaN(601, length(goodSeg))];
                end
                
                try
                    itiWhiskAngPre = mouseSummCell{i,19};
                    for k = 1:size(itiWhiskAngPre,2)
                    itiWhiskAngleSess(:,k) = interp1(linspace(-2,8,size(itiWhiskAngPre,1)), itiWhiskAngPre(:,k), -2:0.1:8);
                    end
                    
                    itiWhiskAngle = [itiWhiskAngle itiWhiskAngleSess];
                catch
                    itiWhiskAngle = [itiWhiskAngle NaN(101, 1)];
                end
                
                numUnits = numUnits + length(goodSeg);
            catch
            end
            
        end
        
    end
    
end


% save to output structure
mouseSummCellCompilStruc.mouseName = mouseSummCell{1,1};
mouseSummCellCompilStruc.mousePath = pwd;
mouseSummCellCompilStruc.rewEpRateMat = rewEpRateMat;
mouseSummCellCompilStruc.rewTrackUnits = rewTrackUnits;
mouseSummCellCompilStruc.randRewUnits = randRewUnits;
mouseSummCellCompilStruc.unitIsoLick = unitIsoLick;
mouseSummCellCompilStruc.unitRandRewCa = unitRandRewCa;
mouseSummCellCompilStruc.unitItiWhiskCa = unitItiWhiskCa;
mouseSummCellCompilStruc.itiWhiskAngle = itiWhiskAngle;
mouseSummCellCompilStruc.unitWhiskXcorr = unitWhiskXcorr;




%% Plotting

% epoch randRewTrack scatter
figure;
subplot(2,3,1);
scatterUnitEpochRew4Del(rewEpRateMat, randRewUnits, rewTrackUnits);


% ca avg
neither = setxor(1:numUnits, [randRewUnits rewTrackUnits]);

try
    %figure;
    subplot(2,3,2);
    plotMeanSEM(unitIsoLick(:,neither), 'b'); % unitIsoLick, 'b');
    hold on;
    plotMeanSEM(unitIsoLick(:,randRewUnits), 'g');
    plotMeanSEM(unitIsoLick(:,rewTrackUnits), 'r');
    legend('non-rew units', 'randRewUnits', 'rewTrackUnits');
    title('unitIsoLickCa');
catch
end

try
    %figure;
    subplot(2,3,3);
    plotMeanSEM(unitRandRewCa(:,neither), 'b'); %unitRandRewCa, 'b');
    hold on;
    plotMeanSEM(unitRandRewCa(:,randRewUnits), 'g');
    plotMeanSEM(unitRandRewCa(:,rewTrackUnits), 'r');
    legend('non-rew units', 'randRewUnits', 'rewTrackUnits');
    
    title('unitRandRewCa');
catch
end

if forWhisk
    try
        %figure;
        subplot(2,3,4);
        plotMeanSEM(unitItiWhiskCa(:,neither), 'b'); % unitIsoLick, 'b');
        hold on;
        plotMeanSEM(unitItiWhiskCa(:,randRewUnits), 'g');
        plotMeanSEM(unitItiWhiskCa(:,rewTrackUnits), 'r');
        legend('non-rew units', 'randRewUnits', 'rewTrackUnits');
        title('unitItiWhiskCa');
    catch
    end
    
    try
        %figure;
        subplot(2,3,5);
        plotMeanSEM(itiWhiskAngle, 'b'); % unitIsoLick, 'b');
        title('itiWhiskAngle');
    catch
    end
    
    try
        for j = 1:size(unitWhiskXcorr,2)
            unitWhiskXcorr2(:,j) = decimate(unitWhiskXcorr(:,j),10);
        end

        %figure;
        subplot(2,3,6);
        plotMeanSEM(unitWhiskXcorr2(:,neither), 'b'); % unitIsoLick, 'b');
        hold on;
        plotMeanSEM(unitWhiskXcorr2(:,randRewUnits), 'g');
        plotMeanSEM(unitWhiskXcorr2(:,rewTrackUnits), 'r');
        legend('non-rew units', 'randRewUnits', 'rewTrackUnits');
        title('unitWhiskXcorr');
    catch
    end
end


