function [multMouseSummStruc] = compileMouseSummCompilStruc(mouseSummCellCompilStruc, multMouseSummStruc, unitRange, toPlot)


fieldNames = fieldnames(mouseSummCellCompilStruc);

try
    numPrevUnits = size(multMouseSummStruc.unitRandRewCa,2);
catch
    numPrevUnits = 0;
end


for i = 4:length(fieldNames)
    fieldVals = mouseSummCellCompilStruc.(fieldNames{i});
    
    if strfind(fieldNames{i}, 'Units')
        fieldVals = fieldVals(fieldVals>=unitRange(1) & fieldVals<=unitRange(end));
        %numPrevUnits = ;
        fieldVals = fieldVals + numPrevUnits - unitRange(1)+1;
        try
            multMouseSummStruc.(fieldNames{i}) = [multMouseSummStruc.(fieldNames{i}) fieldVals];
        catch
            multMouseSummStruc.(fieldNames{i}) = fieldVals;
        end
    elseif strfind(fieldNames{i}, 'itiWhiskAngle')
        try
            multMouseSummStruc.(fieldNames{i}) = [multMouseSummStruc.(fieldNames{i}) fieldVals];
        catch
            multMouseSummStruc.(fieldNames{i}) = fieldVals;
        end
    else
        try
            multMouseSummStruc.(fieldNames{i}) = [multMouseSummStruc.(fieldNames{i}) fieldVals(:,unitRange)];
        catch
            multMouseSummStruc.(fieldNames{i}) = fieldVals(:,unitRange);
        end
        
    end
end


%% Plotting


randRewUnits = multMouseSummStruc.randRewUnits;
rewTrackUnits = multMouseSummStruc.rewTrackUnits;
unitIsoLick = multMouseSummStruc.unitIsoLick;
unitRandRewCa = multMouseSummStruc.unitRandRewCa;
unitItiWhiskCa = multMouseSummStruc.unitItiWhiskCa;
itiWhiskAngle = multMouseSummStruc.itiWhiskAngle;
unitWhiskXcorr = multMouseSummStruc.unitWhiskXcorr;

if toPlot

% ca avg
neither = setxor(1:size(unitIsoLick,2), [randRewUnits rewTrackUnits]);

figure;
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

%if forWhisk
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
%end

end