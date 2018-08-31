function [whCaXCorrGroupStruc] = whiskCaEpochXCorrMouse()


% This is a script to search through all of the days in a directory (e.g.
% motionCorrected/toCorrect) and 

% saveMem variable just changes the way MP4 files are loaded using extractStimFrames, which is
% slower I think, but doesn't take as much RAM

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
                
                if ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'whiskDataStruc'))))
                    whiskDataDirInd = find(cellfun(@length, strfind(sessionFilenames, 'whiskDataStruc')));
                    load(sessionDir(whiskDataDirInd).name);
                    
                    try
                    
                    disp(['Processing whiskCaEpochXCorr for ' sessionName]); tic;
                        [whiskCaXCorrStruc] = whiskCaEpochXCorrPS3(0); toc;
                        numSessions = numSessions + 1;
                        whCaXCorrGroupStruc.sessionNameCell{numSessions} = sessionName;
                        %whCaXCorrGroupStruc.frameRates(numSessions) = whiskCaXCorrStruc.frameRate;
                        whCaXCorrGroupStruc.allItiXcorr(:,numSessions) = mean(whiskCaXCorrStruc.allItiXcorr,1);
                        whCaXCorrGroupStruc.randRewItiXcorr(:,numSessions) = nanmean(whiskCaXCorrStruc.randRewItiXcorr,1);
                        whCaXCorrGroupStruc.normalItiXcorr(:,numSessions) = mean(whiskCaXCorrStruc.normalItiXcorr,1);
                        
                        whCaXCorrGroupStruc.allStimXcorr(:,numSessions) = mean(whiskCaXCorrStruc.allStimXcorr,1);
                        whCaXCorrGroupStruc.rewStimXcorr(:,numSessions) = mean(whiskCaXCorrStruc.rewStimXcorr,1);
                        whCaXCorrGroupStruc.unrewStimXcorr(:,numSessions) = mean(whiskCaXCorrStruc.unrewStimXcorr,1);
                        whCaXCorrGroupStruc.correctRewXcorr(:,numSessions) = mean(whiskCaXCorrStruc.correctRewXcorr,1);
                        whCaXCorrGroupStruc.incorrectRewXcorr(:,numSessions) = mean(whiskCaXCorrStruc.incorrectRewXcorr,1);
                        whCaXCorrGroupStruc.correctUnrewXcorr(:,numSessions) = mean(whiskCaXCorrStruc.correctUnrewXcorr,1);
                        whCaXCorrGroupStruc.incorrectUnrewXcorr(:,numSessions) = mean(whiskCaXCorrStruc.incorrectUnrewXcorr,1);
                        
                        whCaXCorrGroupStruc.fullSessionXcorr(:,numSessions) = whiskCaXCorrStruc.fullSessionXcorr;
                        
                    catch
                        disp(['Failed to process whisker video for ' sessionName]);
                    end
                    
                else
                    disp(['No whiskerDataStruc for ' sessionName]);
                    
                end  % end IF no previous whiskDataStruc
                
            end  % end IF dayDir entry isdir  (i.e. is a session folder)
        end  % end FOR looking through dayDir
    end  % end IF mouseDir entry isdir  (i.e. is a day folder)
end % end FOR looking through mouseDir

disp('Saving whCaXCorrGroupStruc');
cd(folderPath);
save(['whCaXCorrGroupStruc_' mouseName '_' date], 'whCaXCorrGroupStruc');

figure; hold on;
plot(nanmean(whCaXCorrGroupStruc.allItiXcorr, 2), 'm');
plot(nanmean(whCaXCorrGroupStruc.randRewItiXcorr, 2),'b');
plot(nanmean(whCaXCorrGroupStruc.rewStimXcorr, 2), 'g');
plot(nanmean(whCaXCorrGroupStruc.unrewStimXcorr, 2), 'r');
plot(nanmean(whCaXCorrGroupStruc.fullSessionXcorr, 2), 'c');
legend('allITIs', 'randRewITIs', 'stimTrials', 'catchTrials', 'fullSession(10x)');
title([mouseName ' whiskCaXCorrGroup on ' date]);

