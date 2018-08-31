function [filenameCell] = findDataFilenames(outStruc)

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

filenameCell = {};
numFiles = 0;

% just load in some common variable to check for exact match
rewCa = outStruc.rewStimStimIndCaAvg;
rewCa1 = rewCa(1,:);

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
    
    disp(['Processing mouse ' mouseName]); tic;
    
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
                    try
                        load(sessionDir(dbsInd(latestDbsInd)).name);
                        rewVal1 = dendriteBehavStruc.rewStimStimIndCaAvg(1);
                        dataInd = find(rewCa1 == rewVal1);
                        
                        if ~isempty(dataInd)
                            filenameCell{dataInd} = sessionName;
                        end
                    catch
                    end
                end  % end IF dayDir entry isdir  (i.e. is a session folder)
            end  % end FOR looking through dayDir
        end  % end IF mouseDir entry isdir  (i.e. is a day folder)
    end % end FOR looking through mouseDir
end % end FOR looking through all mice from which data in dataset came


















