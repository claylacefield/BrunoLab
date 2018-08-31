function [unitRewDelayStruc] = unitRewDelayCaMouse(dataFileArray, goodSegTag, toSave)




% This script goes through all the units in a mouse folder
% and finds the rewDelay calcium, then compiles for all goodSegs

% NOTE: I don't think I'm going to use the same units as in the randRew
% analysis, i.e. in the previous I only took units that were from days with
% at least 3 randRew, but here I'm going to use all days because I don't
% think I'm going to use this along with the randRew analysis




% This function goes through a mouse folder, goes to each session and
% compiles the rewDelay 

% create output structure
% every trial from every unit?
% average over all trials from every unit

unitRewDelayStruc.rewStimCaAvg = [];


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
                        
                        
                        if proc == 1
                            try
                            totalSessNum = totalSessNum + 1;
                            unitRewDelayStruc.filenameCell{totalSessNum} = filename;
                            unitRewDelayStruc.numGoodSeg(totalSessNum) = length(goodSeg);
                            
                            mouseUnitEpochSortStruc.rewStimCa{totalSessNum} = squeeze(segStruc.rewStimStimIndCa(:,goodSeg,:)); % [mouseUnitEpochSortStruc.rewStimCaAvg avCa(:,goodSeg)];
                            
                            % extract calcium profiles for all the units
                            %avCa = mean(segStruc.rewStimStimIndCa, 3);
                            
                            unitRewDelayStruc.rewDelay1TimeCa{totalSessNum} = squeeze(segStruc.rewDelay1TimeCa(:,goodSeg,:)); % [unitRewDelayStruc.rewStimCaAvg avCa(:,goodSeg)];
                            unitRewDelayStruc.rewDelay2TimeCa{totalSessNum} = squeeze(segStruc.rewDelay2TimeCa(:,goodSeg,:));
                            unitRewDelayStruc.rewDelay3TimeCa{totalSessNum} = squeeze(segStruc.rewDelay3TimeCa(:,goodSeg,:));
                            catch
                                disp('Problem processing rewDelay');
                            end
                            
                            try
                            eventType = 'isoLevLiftTime';
                            [hitFAeventCa, missCReventCa] = unitHitFAmissCRca(dendriteBehavStruc, segStruc, eventType);
                            unitRewDelayStruc.hitFAeventCa{totalSessNum} = squeeze(hitFAeventCa(:,goodSeg,:));
                            unitRewDelayStruc.missCReventCa{totalSessNum} = squeeze(missCReventCa(:,goodSeg,:));
                            catch
                                disp('Could not calculate hitFAmissCR for this session');
                            end

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
unitRewDelayStruc.mouseFolder = mouseFolder;
unitRewDelayStruc.mouseName = mouseName;

if toSave
save([mouseName '_unitRewDelayStruc_' date], 'unitRewDelayStruc');
end

catch
    disp('Problem saving');
end


% now sort all of the resulting units (by session or alltogether?)
%[ca2] = sortUnitsByTime(segStruc, goodSeg);


