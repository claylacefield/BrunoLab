function [unitRew4DelayStruc] = unitRew4DelayCaMouse(fileTag, procSomaOrDend, goodGreatSeg, toSave)


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

unitRew4DelayStruc.rewStimCaAvg = [];

unitRew4DelayStruc.rewEpRate = [];
unitRew4DelayStruc.rewEpRate2 = [];
unitRew4DelayStruc.rewEpRateAdj = [];
unitRew4DelayStruc.rewEpRate2Adj = [];


unitRew4DelayStruc.unitRandRewPvalArr = [];



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
        
        for b = 3:length(dayDir)   % for each file in this day (now, folder with tif)
            if dayDir(b).isdir
                
                 try
                    
                    sessionName = dayDir(b).name;
                    
                    cd([dayPath '/' sessionName]);
                    
                    filename = [dayDir(b).name '.tif'];
                    
                    filename = filename(1:(strfind(filename, '.tif')+3));
                    
                    
                    %% see if correct somaDend (if desired)
                    if procSomaOrDend ~= 0  % if you want to look for somaDend
                        somaDendName = findLatestFilename('somaDend');
                        load(somaDendName, 'somaDend');
                        
                        if  contains(somaDend, procSomaOrDend)
                            toProcess = 1;
                        else
                            disp('Wrong somaDend');
                            toProcess = 0;
                        end
                        
                    else
                        toProcess = 1;
                    end
                    
                    %% and correct behavioral program
                    txtFilename = findLatestFilename('.txt');
                    programName = readArduinoProgramName(txtFilename);
                    
                    if iscell(fileTag)
                        progTag = fileTag{1};
                        progNotTag = fileTag{2};
                    else
                        progTag = fileTag;
                        progNotTag = 'nothing';
                    end
                    
                    if toProcess==1 && contains(programName, progTag) && ~contains(programName, progNotTag)
                        toProcess = 1;
                    else
                        toProcess = 0;
                    end
                    
                    % if it is correct session type
                    
                    if toProcess
                        
                        disp(['Starting analysis of ' filename ' ...']);
                        
                        proc = 1;
                        
                        basename = filename(1:(strfind(filename, '.tif')-1));
                        cd([dayPath basename]);
                        
                        tifDir = dir;
                        
                        %fps = dataFileArray{rowInd, 6};
                        
                        % load in correct dendriteBehavStruc, segStruc, and goodSegs
                        
                        % load in this segStruc
                        disp(['loading in previously segmented file: ']); tic;
                        segFilename = findLatestFilename('_seg_');
                        load(segFilename);
                        toc;
                        
                        
                        % load in this dendriteBehavStruc
                        disp(['loading in latest dendriteBehavStruc: ']); tic;
                        dbsFilename = findLatestFilename('dendriteBehavStruc');
                        load(dbsFilename); toc;
                        
                        % find goodSeg files
                        % and load in goodSeg
                        try
                            if contains(goodGreatSeg, 'good')
                                goodSegFilename = findLatestFilename('_goodSeg_');
                                load(goodSegFilename);
                            elseif contains(goodGreatSeg, 'great')
                                goodSegFilename = findLatestFilename('_greatSeg_');
                                load(goodSegFilename);
                                goodSeg = greatSeg;
                            end
                        catch
                            disp('No goodSegs');
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
                            unitRew4DelayStruc.filenameCell{totalSessNum} = filename;
                            unitRew4DelayStruc.numGoodSeg(totalSessNum) = length(goodSeg);
                            
                            
                            % extract calcium profiles for all the units
                            %avCa = mean(segStruc.rewStimStimIndCa, 3);
                            
                            unitRew4DelayStruc.rewStimCa{totalSessNum} = squeeze(segStruc.rewStimStimIndCa(:,goodSeg,:)); % [unitRew4DelayStruc.rewStimCaAvg avCa(:,goodSeg)];
                            
                            % find the unitEpochStruc (firing rate in diff epochs)
                            disp('Calculating unitEpochStruc'); tic;
                            %scaleRoiHist = 1;
                            [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg); %, scaleRoiHist);
                            unitRew4DelayStruc.rewEpRate = [unitRew4DelayStruc.rewEpRate; unitEpochStruc.rewEpRate];
                            unitRew4DelayStruc.rewEpRate2 = [unitRew4DelayStruc.rewEpRate2; unitEpochStruc.rewEpRate2];
                            unitRew4DelayStruc.rewEpRateAdj = [unitRew4DelayStruc.rewEpRateAdj; unitEpochStruc.rewEpRateAdj];
                            unitRew4DelayStruc.rewEpRate2Adj = [unitRew4DelayStruc.rewEpRate2Adj; unitEpochStruc.rewEpRate2Adj];
                            toc;
                            
                            % calculate unit firing to randRew
                            disp('Calculating unitRandRewITIproportion'); tic;
                            toPlot = 0;
                            [unitItiPropStruc] = unitRandRewITIproportion(dendriteBehavStruc, segStruc, goodSeg, unitEpochStruc, toPlot);
                            unitPropArr = unitItiPropStruc.unitPropArr;
                            unitRandRewPval = unitItiPropStruc.unitRandRewPval;
                            unitRew4DelayStruc.unitRandRewPvalArr = [unitRew4DelayStruc.unitRandRewPvalArr unitRandRewPval];
                            toc;
                            %                     catch
                            %                         disp(['Problem analyzing ' filename]);
                            %                     end
                            
                            try
                                unitRew4DelayStruc.rewDelay1TimeCa{totalSessNum} = squeeze(segStruc.rewDelay1TimeCa(:,goodSeg,:)); % [unitRew4DelayStruc.rewStimCaAvg avCa(:,goodSeg)];
                                unitRew4DelayStruc.rewDelay2TimeCa{totalSessNum} = squeeze(segStruc.rewDelay2TimeCa(:,goodSeg,:));
                                unitRew4DelayStruc.rewDelay3TimeCa{totalSessNum} = squeeze(segStruc.rewDelay3TimeCa(:,goodSeg,:));
                            catch
                                disp('Problem processing rewDelay');
                            end
                            
                            try
                                eventType = 'isoLevLiftTime';
                                [hitFAeventCa, missCReventCa] = unitHitFAmissCRca(dendriteBehavStruc, segStruc, eventType);
                                unitRew4DelayStruc.hitFAeventCa{totalSessNum} = squeeze(hitFAeventCa(:,goodSeg,:));
                                unitRew4DelayStruc.missCReventCa{totalSessNum} = squeeze(missCReventCa(:,goodSeg,:));
                            catch
                                disp('Could not calculate hitFAmissCR for this session');
                            end
                            
                        end  % end IF cond for proc == 1
                    end  % end IF cond to make sure it's not a stage1 file
                catch
                    disp('Problem processing this session');
                end
            end  % end IF cond for isdir(sessionFolder)
        end  % end FOR loop for all files in that day
    end  % end IF cond for isdir(dayFolder)
end  % end FOR loop for all days in mouseFolder

cd(mouseFolder);

try
    mouseName = mouseFolder((strfind(mouseFolder, '/mouse')+6):end);
    unitRew4DelayStruc.mouseFolder = mouseFolder;
    unitRew4DelayStruc.mouseName = mouseName;
    
    if toSave
        save([mouseName '_unitRew4DelayStruc_' date], 'unitRew4DelayStruc');
    end
    
catch
    disp('Problem saving');
end


% now sort all of the resulting units (by session or alltogether?)
%[ca2] = sortUnitsByTime(segStruc, goodSeg);


