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
                        whCaXCorrGroupStruc.allItiXcorr(:,numSessions) = whiskCaXCorrStruc.allItiXcorr;
                        whCaXCorrGroupStruc.randRewItiXcorr(:,numSessions) = whiskCaXCorrStruc.randRewItiXcorr;
                        whCaXCorrGroupStruc.normalItiXcorr(:,numSessions) = whiskCaXCorrStruc.normalItiXcorr;
                        
                        whCaXCorrGroupStruc.allStimXcorr(:,numSessions) = whiskCaXCorrStruc.allStimXcorr;
                        whCaXCorrGroupStruc.rewStimXcorr(:,numSessions) = whiskCaXCorrStruc.rewStimXcorr;
                        whCaXCorrGroupStruc.unrewStimXcorr(:,numSessions) = whiskCaXCorrStruc.unrewStimXcorr;
                        whCaXCorrGroupStruc.correctRewXcorr(:,numSessions) = whiskCaXCorrStruc.correctRewXcorr;
                        whCaXCorrGroupStruc.incorrectRewXcorr(:,numSessions) = whiskCaXCorrStruc.incorrectRewXcorr;
                        whCaXCorrGroupStruc.correctUnrewXcorr(:,numSessions) = whiskCaXCorrStruc.correctUnrewXcorr;
                        whCaXCorrGroupStruc.incorrectUnrewXcorr(:,numSessions) = whiskCaXCorrStruc.incorrectUnrewXcorr;
                        
                        whCaXCorrGroupStruc.fullSession(:,numSessions) = whiskCaXCorrStruc.fullSessionXcorr;
                        
                        
                        
                        
                        
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
plot(nanmean(whCaXCorrGroupStruc.allITIs, 2), 'm');
plot(nanmean(whCaXCorrGroupStruc.randRewITIs, 2),'b');
plot(nanmean(whCaXCorrGroupStruc.stimTrials, 2), 'g');
plot(nanmean(whCaXCorrGroupStruc.catchTrials, 2), 'r');
plot(10*nanmean(whCaXCorrGroupStruc.fullSession, 2), 'c');
legend('allITIs', 'randRewITIs', 'stimTrials', 'catchTrials', 'fullSession(10x)');
title([mouseName ' whiskCaXCorrGroup on ' date]);

