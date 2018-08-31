function [goodSessionStruc, goodEventHistStruc] = findGoodCaEventHistSessions(fieldThresh)

% This is a function to find the particular sessions that comprise the
% rewDelayGroup44sessions dataset, which I had originally hand-selected
% (think based upon rewStimIndCaAvg > 0.05) but the selection gui didn't
% record the filenames for.
% This is important because in order to find out other corresponding
% information from these datasets that are not included in
% dendriteBehavStruc, I need to know which these are. For instance, to find
% the timecourses of different responses.
% I may also integrate a script (or probably just make another one) to
% automatically select datasets based upon these criteria. I should also
% possibly include a check on the dataFileArray to see what layer they are,
% because I realize that some of the R11 data (I think) was actually from
% somata

sessionNameCell = {};
numFiles = 0;
mouseNameCell = {};
dbsFilenameCell = {};


filterField = 'rewDelay2TimeCaAvg';

% just load in some common variable to check for exact match
% rewCa = outStruc.rewStimStimIndCaAvg;
% rewCa1 = rewCa(1,:);

fieldnamesPath = '/home/clay/Documents/Data/2p mouse behavior/masterFieldNamesCaCaAvg_110814.mat';
load(fieldnamesPath);

for field = 1:length(masterFieldNamesCaAvg)
    
    goodSessionStruc.(masterFieldNamesCaAvg{field}) = [];
    
end


fieldnamesPath = '/home/clay/Documents/Data/2p mouse behavior/masterFieldNamesEventHist_091215b.mat';
load(fieldnamesPath);

for field = 1:length(masterFieldNamesEventHist)
    
    goodEventHistStruc.(masterFieldNamesEventHist{field}) = [];
    
end


mouseList = {'mouseR103' 'mouseR101' 'mouseR102' 'mouseR111' 'mouseR112'};
mouseFolderList = {'R10b' 'R10a' 'R10a' 'R11' 'R11'};

genoPath = '/home/clay/Documents/Data/2p mouse behavior/Rbp4';
cd(genoPath);

genoDir = dir;

cageNames = {genoDir.name};

for mouseInd = 1:length(mouseList)
    mouseName = mouseList{mouseInd};
    mouseFolder = mouseFolderList{mouseInd};
    mousePath = [genoPath '/' mouseFolder '/' mouseName];
    cd(mousePath);
    
    mouseDir = dir;
    
    disp(['Processing ' mouseName]); tic;
    
    for mouseDirInd = 3:length(mouseDir)
        
        if mouseDir(mouseDirInd).isdir
            dayName = mouseDir(mouseDirInd).name;
            dayPath = [mousePath '/' dayName];
            cd(dayPath);
            
            dayDir = dir;
            
            for dayDirInd = 3:length(dayDir)
                
                if dayDir(dayDirInd).isdir
                    sessionName = dayDir(dayDirInd).name;
                    sessionPath = [dayPath '/' sessionName];
                    cd(sessionPath);
                    
                    sessionDir = dir;
                    
                    sessionDirNames = {sessionDir.name};
                    
                    dbsInd = find(cellfun(@length, strfind(sessionDirNames, 'dendriteBehavStruc')));
                    dbsDatenums = [sessionDir(dbsInd).datenum];
                    [lsaMax, lastInd] = max(dbsDatenums);
                    latestDbsInd = dbsInd(lastInd);
                    
                    evHisInd = find(cellfun(@length, strfind(sessionDirNames, 'eventHistBehavStruc')));
                    evHisDatenums = [sessionDir(evHisInd).datenum];
                    [lsaMax, lastInd] = max(evHisDatenums);
                    latestEvHisInd = evHisInd(lastInd);
                    
                    if ~isempty(dbsInd)
                        
                        filename = sessionDir(latestDbsInd).name;
                        
                        
                        try
                            disp(['Loading latest file ' filename]);
                            load(filename);
                            load(sessionDir(latestEvHisInd).name);
                        catch
                            disp(['Problem loading ' filename]);
                        end
                        
                        try
                            rewCa = dendriteBehavStruc.(filterField);
                        catch
                            disp('No rewDelay2Time');
                        end
                        
                        try
                            %maxCa = max(rewCa);
                            
                            if max(rewCa(4:12)) >= fieldThresh
                                numFiles = numFiles + 1;
                                sessionNameCell{numFiles} = sessionName;
                                mouseNameCell{numFiles} = mouseName;
                                dbsFilenameCell{numFiles} = filename;
                                disp(['Found dataset ' filename]);
                                
                                [goodSessionStruc] = compileFields(goodSessionStruc, dendriteBehavStruc,33);
                                
                                
                                [goodEventHistStruc] = compileFields(goodEventHistStruc, eventHistBehavStruc,8001);
                                
                                
                            end
                        catch
                            disp(['Some other problem with ' filename]);
                        end
                    end % end IF ~isempty(dbsInd)
                end  % end IF dayDir entry isdir  (i.e. is a session folder)
            end  % end FOR looking through dayDir
        end  % end IF mouseDir entry isdir  (i.e. is a day folder)
    end % end FOR looking through mouseDir
end % end FOR looking through all mice from which data in dataset came


goodSessionStruc.mouseNameCell = mouseNameCell;
goodSessionStruc.sessionNameCell = sessionNameCell;
goodSessionStruc.dbsFilenameCell = dbsFilenameCell;
goodSessionStruc.fieldThresh = fieldThresh;

figure; 

subplot(2,1,1);  
plot(nanmean(goodSessionStruc.rewDelay3TimeCaAvg,2),'b');
title(['rewDelay2Time thresh = ' num2str(fieldThresh)]);
hold on; 
plot(nanmean(goodSessionStruc.rewTime5CaAvg,2),'r');
legend('rewDelay3Time', 'rewTime5');
hold off;


subplot(2,1,2);
plot(nanmean(goodSessionStruc.rewDelay3TimeCaAvg,2),'g');
hold on; 
plot(nanmean(goodSessionStruc.rewTime4CaAvg,2),'b');
legend('rewDelay3Time', 'rewTime4');
hold off;


%% now plot event hist (whisk contacts)

wDel1 = nanmean(goodEventHistStruc.rewDelay1TimeEventHist, 2);
wDel3 = nanmean(goodEventHistStruc.rewDelay3TimeEventHist, 2);

[wDel1b] = histBin(wDel1, 250);
[wDel3b] = histBin(wDel3, 250);

figure; 
subplot(2,1,1);  
plot(nanmean(goodSessionStruc.rewDelay1TimeCaAvg,2),'b');
title(['rewDelay2Time thresh = ' num2str(fieldThresh)]);
hold on; 
plot(nanmean(goodSessionStruc.rewDelay3TimeCaAvg,2),'g');
legend('rewDelay1Time', 'rewDelay3Time');
hold off;


subplot(2,1,2);
bar(wDel1b, 'b'); 
hold on; 
bar(wDel3b, 'g'); 
legend('rewDelay1Time', 'rewDelay3Time');
hold off;










