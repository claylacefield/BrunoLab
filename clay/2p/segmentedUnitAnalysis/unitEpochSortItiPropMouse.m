function [mouseUnitEpochSortStruc] = unitEpochSortItiPropMouse(dataFileArray, goodSegTag, toSave)


% This function goes through a mouse folder, goes to each session and
% calculates the goodSeg unit properties such as:
% 1.) firing rate in different time epochs
% 2.) time of peak firing
% 3.) proportion of randRew events vs normal ITIs

% NOTE: most of these are based upon the trial-triggered rewStimStimInd and
% unrewStimStimInd


% create output structure
% every trial from every unit?
% average over all trials from every unit

mouseUnitEpochSortStruc.rewStimCaAvg = [];

mouseUnitEpochSortStruc.rewEpRate = [];
mouseUnitEpochSortStruc.rewEpRate2 = [];
mouseUnitEpochSortStruc.rewEpRateAdj = [];
mouseUnitEpochSortStruc.rewEpRate2Adj = [];


mouseUnitEpochSortStruc.unitRandRewPvalArr = [];



totalSessNum = 0;

% select mouse folder to analyze
mouseFolder = uigetdir;      % select the cage folder to analyze

cd(mouseFolder);
[pathname mouseName] = fileparts(mouseFolder);
mouseDir = dir;

for a = 3:length(mouseDir) % for each day of imaging in this animal's dir
    
    if mouseDir(a).isdir %&& totalSessNum <= 3
        
        dayPath = [mouseFolder '/' mouseDir(a).name '/'];
        
        cd(dayPath); % go to this day of imaging
        
        dayDir = dir;
        
        for b = 3:length(dayDir);   % for each file in this day (now, folder with tif)
            if dayDir(b).isdir
                
                % see if this file is on the dataFileArray TIF list (and if so, what
                % row?)
                filename = [dayDir(b).name '.tif'];
                
                filename = filename(1:(strfind(filename, '.tif')+3));
                
                rowInd = find(strcmp(filename, dataFileArray(:,1)));
                
                if isempty(rowInd)
                    filename2 = [filename ''''];
                    rowInd = find(strcmp(filename2, dataFileArray(:,1)));
                end
                
                % if it is in list (and not stage1), then process data
                
                if rowInd
                    
                    if isempty(strfind(dataFileArray{rowInd,8}, 'stage'))
                        
                        disp(['Starting analysis of ' filename ' ...']);
                        
                        proc = 1;
                        
                        basename = filename(1:(strfind(filename, '.tif')-1));
                        cd([dayPath basename]);
                        
                        tifDir = dir;
                        
                        fps = dataFileArray{rowInd, 6};
                        
                        % load in correct dendriteBehavStruc, segStruc, and goodSegs
                        %                     try
                        % find tifDir indices of seg files
                        segInd = find(cellfun(@length, strfind({tifDir.name}, 'seg')));
                        % find the latest seg file index
                        segDatenums = [tifDir(segInd).datenum];
                        [lsaMax, lastSegArrInd] = max(segDatenums);
                        latestSegInd = segInd(lastSegArrInd);
                        % load in this segStruc
                        disp(['loading in previously segmented file: ' tifDir(latestSegInd).name]); tic;
                        load(tifDir(latestSegInd).name); toc;
                        
                        % find tifDir indices of dendriteBehavStruc files
                        dbsInd = find(cellfun(@length, strfind({tifDir.name}, 'dendriteBehavStruc')));
                        % find the latest dendriteBehavStruc file index
                        dbsDatenums = [tifDir(dbsInd).datenum];
                        [lsaMax, lastSegArrInd] = max(dbsDatenums);
                        latestDbsInd = dbsInd(lastSegArrInd);
                        % load in this dendriteBehavStruc
                        disp(['loading in latest dendriteBehavStruc: ' tifDir(latestDbsInd).name]); tic;
                        load(tifDir(latestDbsInd).name); toc;
                        
                        % find tifDir indices of goodSeg files
                        goodsegInd = find(cellfun(@length, strfind({tifDir.name}, 'goodSeg')));
                        filterInd = find(cellfun(@length, strfind({tifDir.name}, goodSegTag)));
                        goodsegInd = intersect(goodsegInd, filterInd);
                        
                        if ~isempty(goodsegInd)
                        
                        % find the latest goodSeg file index
                        goodsegDatenums = [tifDir(goodsegInd).datenum];
                        [lsaMax, lastGoodsegArrInd] = max(goodsegDatenums);
                        latestGoodsegInd = goodsegInd(lastGoodsegArrInd);
                        % load in this goodSeg
                        disp(['loading in latest goodSeg file: ' tifDir(latestGoodsegInd).name]); tic;
                        load(tifDir(latestGoodsegInd).name); toc;
                        
                        else
                            disp('Cant find appropriate goodSeg file, so skipping');
                            proc = 0;
                        end
                        
                        %proc = 1;
                        try
                            rew4 = dendriteBehavStruc.rewTime4Ca;
                            
                            % also, don't process if very few randRew
                            if size(rew4,2) < 3
                                disp(['Too few (<3) random rewards in ' filename ' so not processing']);
                                proc = 0;
                            end
                            
                        catch
                            disp(['No random rewards in ' filename ' so not processing']);
                            proc = 0;
                        end  % end TRY/CATCH checking to see if any randRew
                        
                        
                        
                        if proc == 1
                            totalSessNum = totalSessNum + 1;
                            mouseUnitEpochSortStruc.filenameCell{totalSessNum} = filename;
                            mouseUnitEpochSortStruc.numGoodSeg(totalSessNum) = length(goodSeg);
                            
                            
                            % extract calcium profiles for all the units
                            avCa = mean(segStruc.rewStimStimIndCa, 3);
                            mouseUnitEpochSortStruc.rewStimCaAvg = [mouseUnitEpochSortStruc.rewStimCaAvg avCa(:,goodSeg)];
                            
                            % find the unitEpochStruc (firing rate in diff epochs)
                            disp('Calculating unitEpochStruc'); tic;
                            %scaleRoiHist = 1;
                            [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg); %, scaleRoiHist);
                            mouseUnitEpochSortStruc.rewEpRate = [mouseUnitEpochSortStruc.rewEpRate; unitEpochStruc.rewEpRate];
                            mouseUnitEpochSortStruc.rewEpRate2 = [mouseUnitEpochSortStruc.rewEpRate2; unitEpochStruc.rewEpRate2];
                            mouseUnitEpochSortStruc.rewEpRateAdj = [mouseUnitEpochSortStruc.rewEpRateAdj; unitEpochStruc.rewEpRateAdj];
                            mouseUnitEpochSortStruc.rewEpRate2Adj = [mouseUnitEpochSortStruc.rewEpRate2Adj; unitEpochStruc.rewEpRate2Adj];
                            toc;
                            
                            % calculate unit firing to randRew
                            disp('Calculating unitRandRewITIproportion'); tic;
                            toPlot = 0;
                            [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot);
                            unitPropArr = unitItiPropStruc.unitPropArr;
                            unitRandRewPval = unitItiPropStruc.unitRandRewPval;
                            mouseUnitEpochSortStruc.unitRandRewPvalArr = [mouseUnitEpochSortStruc.unitRandRewPvalArr unitRandRewPval];
                            toc;
                            %                     catch
                            %                         disp(['Problem analyzing ' filename]);
                            %                     end
                            
                        end  % end IF cond for proc == 1
                    end  % end IF cond to make sure it's not a stage1 file
                end  % end IF cond for whether session in dataFileArray
            end  % end IF cond for isdir(sessionFolder)
        end  % end FOR loop for all files in that day
    end  % end IF cond for isdir(dayFolder)
end  % end FOR loop for all days in mouseFolder

cd(mouseFolder);

try
mouseName = mouseFolder((strfind(mouseFolder, '/mouse')+6):end);
mouseUnitEpochSortStruc.mouseFolder = mouseFolder;
mouseUnitEpochSortStruc.mouseName = mouseName;

if toSave
save([mouseName '_mouseUnitEpochSortStruc_' date], 'mouseUnitEpochSortStruc');
end

catch
    disp('Problem saving');
end


% now sort all of the resulting units (by session or alltogether?)
%[ca2] = sortUnitsByTime(segStruc, goodSeg);


