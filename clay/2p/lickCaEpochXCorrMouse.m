function [lickCaXCorrGroupStruc] = lickCaEpochXCorrMouse()


% This is a script to search through all of the days in a directory (e.g.
% motionCorrected/toCorrect) and 


numSessions = 0;

folderPath = uigetdir;
mouseName = folderPath(strfind(folderPath, '/mouse')+1:end);
cd(folderPath);
folderDir = dir;

for folderDirInd = 3:length(folderDir)
    
    if folderDir(folderDirInd).isdir
        dayName = folderDir(folderDirInd).name;
        dayPath = [folderPath '/' dayName];
        cd(dayPath);
        
        dayDir = dir;
        
        for dayDirInd = 3:length(dayDir)
            
            if dayDir(dayDirInd).isdir
                sessionName = dayDir(dayDirInd).name;
                sessionPath = [dayPath '/' sessionName];
                cd(sessionPath);
                
                sessionDir = dir;
                sessionFilenames = {sessionDir.name};
                
                if ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'dendriteBehavStruc'))))
%                     whiskDataDirInd = find(cellfun(@length, strfind(sessionFilenames, 'whiskDataStruc')));
%                     load(sessionDir(whiskDataDirInd).name);
                    try
                    
                    disp(['Processing lickCaEpochXCorr for ' sessionName]); tic;
                        [lickCaXCorrStruc] = lickCaEpochXCorr(0); toc;
                        numSessions = numSessions + 1;
                        lickCaXCorrGroupStruc.sessionNameCell{numSessions} = sessionName;
                        lickCaXCorrGroupStruc.frameRates(numSessions) = lickCaXCorrStruc.frameRate;
                        lickCaXCorrGroupStruc.allITIs(:,numSessions) = lickCaXCorrStruc.allITIs;
                        lickCaXCorrGroupStruc.randRewITIs(:,numSessions) = lickCaXCorrStruc.randRewITIs;
                        lickCaXCorrGroupStruc.stimTrials(:,numSessions) = lickCaXCorrStruc.stimTrials;
                        lickCaXCorrGroupStruc.catchTrials(:,numSessions) = lickCaXCorrStruc.catchTrials;
                        lickCaXCorrGroupStruc.fullSession(:,numSessions) = lickCaXCorrStruc.fullSession;
                    catch
                        disp(['Failed to process lick/Ca2+ XCorr for ' sessionName]);
                    end
                    
                else
                    disp(['No dendriteBehavStruc for ' sessionName]);
                    
                end  % end IF no previous whiskDataStruc
                
            end  % end IF dayDir entry isdir  (i.e. is a session folder)
        end  % end FOR looking through dayDir
    end  % end IF mouseDir entry isdir  (i.e. is a day folder)
end % end FOR looking through mouseDir

disp('Saving lickCaXCorrGroupStruc');
cd(folderPath);
save(['lickCaXCorrGroupStruc_' mouseName '_' date], 'lickCaXCorrGroupStruc');

figure; hold on;
plot(nanmean(lickCaXCorrGroupStruc.allITIs, 2), 'm');
plot(nanmean(lickCaXCorrGroupStruc.randRewITIs, 2),'b');
plot(nanmean(lickCaXCorrGroupStruc.stimTrials, 2), 'g');
plot(nanmean(lickCaXCorrGroupStruc.catchTrials, 2), 'r');
plot(nanmean(lickCaXCorrGroupStruc.fullSession, 2), 'c');
legend('allITIs', 'randRewITIs', 'stimTrials', 'catchTrials', 'fullSession(10x)');
title([mouseName ' lickCaXCorrGroup on ' date]);

