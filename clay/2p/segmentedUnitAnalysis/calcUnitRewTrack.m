function [unitRewTrackStruc] = calcUnitRewTrack(segStruc, goodSeg, toPlot);

%% USAGE: [unitRewTrackStruc] = calcUnitRewTrack(segStruc, goodSeg);
%   calc unit rewDelay stats ( orig from unitRew4DelHitMissStats2.m)
% 
% mods:
% 012318: interpolate ca data to better estimate peak times
% 012418: 
%   - using findpeaks to detect calcium peaks in 2nd peak timerange
%   - using polyfit to find slope of peak times for each unit

try
    
    % load in rewDelayCa for goodSegs
    try
        rewDelay1TimeCa = squeeze(mean(segStruc.rewDelay1TimeCa(:,goodSeg,:),3));
        rewDelay2TimeCa = squeeze(mean(segStruc.rewDelay2TimeCa(:,goodSeg,:),3));
        rewDelay3TimeCa = squeeze(mean(segStruc.rewDelay3TimeCa(:,goodSeg,:),3));
    catch
        disp('Missing one or more rewDelay fields');
    end
    
    % find peak ind (and vals) for all units
    
    if toPlot
    figure('Position', [0 0 640 480]); hold on;
    end
    
    if size(rewDelay1TimeCa,1) == 33
        for seg = 1:length(goodSeg)
            try
            % find unit 2nd peak time (peaks within certain epoch)
            interpFact = 10; % factor by which to interpolate ca data
            pkThresh = 0.01; %0.016; %0.006;   % min size of ca peaks
            [segDel1CaAvg, x] = interpCa(rewDelay1TimeCa(:,seg), interpFact);
            ca1 = segDel1CaAvg(13*interpFact:20*interpFact);
            %pk1 = LocalMinima(-ca1, 6*interpFact, -mean(ca1))+13*interpFact;
            [pkVal1, pk1] = findpeaks(ca1, 'MinPeakProminence', pkThresh, 'MinPeakDistance',20*interpFact-13*interpFact-1);
            [segDel2CaAvg, x] = interpCa(rewDelay2TimeCa(:,seg), interpFact);
            ca2 = segDel2CaAvg(13*interpFact:20*interpFact);
            %pk2 = LocalMinima(-ca2, 6*interpFact, -mean(ca2))+13*interpFact;
            [pkVal2, pk2] = findpeaks(ca2, 'MinPeakProminence', pkThresh, 'MinPeakDistance',20*interpFact-13*interpFact-1);
            [segDel3CaAvg, x] = interpCa(rewDelay3TimeCa(:,seg), interpFact);
            ca3 = segDel3CaAvg(13*interpFact:20*interpFact);
            %pk3 = LocalMinima(-ca3, 6*interpFact, -mean(ca3))+13*interpFact;
            [pkVal3, pk3] = findpeaks(ca3, 'MinPeakProminence', pkThresh, 'MinPeakDistance',20*interpFact-13*interpFact-1);
            
            pk1 = pk1+13*interpFact; % adjust for start of 2nd pk epoch
            pk2 = pk2+13*interpFact;
            pk3 = pk3+13*interpFact;
            
            % plot all units
            if toPlot
            subplot(6,6,seg); hold on; plot(x, segDel1CaAvg, 'r');
            title(num2str(seg));
            plot(x, segDel2CaAvg, 'g'); plot(x, segDel3CaAvg, 'b');
            t = 1:length(segDel1CaAvg);
            plot(x(pk1), segDel1CaAvg(pk1), 'rX');
            plot(x(pk2), segDel2CaAvg(pk2), 'rX');
            plot(x(pk3), segDel3CaAvg(pk3), 'rX');
            xlim([-2 6]);
            yl = ylim;
            line([0 0], yl);
            end
            
            % make cell array of unit 2nd pk times and vals
            % NOTE: not sure whether vals are absolute or relative from
            % MATLAB findpeaks function
            segDelCell{seg} = [x(pk1) x(pk2) x(pk3); pkVal1 pkVal2 pkVal3];
            
            clear segDel1CaAvg segDel2CaAvg segDel3CaAvg pk1 pk2 pk3 pkVal1 pkVal2 pkVal3;
        
            catch
                segDelCell{seg} = [];
            end
            
            end
    end
    
    
    % now calculate stats based upon rewDelay peak inds
    for seg = 1:length(segDelCell)
        
        try
        % load in peak inds for this unit
        segMaxArr = segDelCell{seg};
        
        % method #1: sum of abs(diff) between delay times (obsolete 012418)
        segDiffInd(seg) = abs(segMaxArr(1,1)-segMaxArr(1,2)) + abs(segMaxArr(1,2)-segMaxArr(1,3)) + abs(segMaxArr(1,1)-segMaxArr(1,3));
        
        % method #2: slope of peak ind for diff rewDelays
        % like in fitRewDelPks.m
        t = [0 0.25 0.5]; t2 = [0 0.5];
        pks = segMaxArr(1,:);
        p = polyfit(t,pks,1);
        y = polyval(p,t2);
        slope = diff(y)/diff(t2);

        segDelSlope(seg) = slope;
        segDelVar(seg) = var(segDelCell{seg}(1,:));
        catch
            segDiffInd(seg) = NaN;
            segDelSlope(seg) = NaN;
        end
    end
    
    
    unitRewTrackStruc.segDelCell = segDelCell; % unit 2nd peak times and amplitudes
    unitRewTrackStruc.segDelVar = segDelVar;    % variance of peak times for each unit
    unitRewTrackStruc.segDiffInd = segDiffInd;  % (obsolete)
    unitRewTrackStruc.segDelSlope = segDelSlope;    % slope of peak times based upon rewDelayTime
    
    % find units with good slope and low var
    goodSlopeInd = find(abs(segDelSlope)<0.5);
    goodVarInd = find(segDelVar < 0.2); % 0.1
    unitRewTrackStruc.rewTrackUnits = intersect(goodSlopeInd, goodVarInd); % NOTE: this is with respect to goodSeg
    
catch
    disp('Prob calculating rewTracking');
end

%%

% rewEpRateCell = segStruc.rewEpRateCell(goodCellInds);
% rewEpRateMat = [];
% rewStimCa = {segStruc.rewStimCa{goodCellInds}};
% rewStimCaArr = [];
% for numSess = 1:length(goodCellInds);
%     rewEpRateMat = cat(1, rewEpRateMat, rewEpRateCell{numSess});
%     rewStimCaAvgSess = squeeze(mean(rewStimCa{numSess},3));
%     rewStimCaArr = [rewStimCaArr rewStimCaAvgSess];
% end
%
%
% %%
% unitRew4DelayStats.rewEpRateMat = rewEpRateMat;
%
% unitRew4DelayStats.unitRandRewPval = [segStruc.unitRandRewPvalCell{goodCellInds}];
% unitRew4DelayStats.rewStimCa = rewStimCaArr;








