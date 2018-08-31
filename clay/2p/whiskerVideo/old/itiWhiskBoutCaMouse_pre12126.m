function [itiWhiskBoutCaMouseStruc] = itiWhiskBoutCaMouse()


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
                
                if ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'whiskDataStruc'))))
                    
                    try
                    
                    disp(['Processing itiWhiskBoutCa for ' sessionName]); tic;
                        [itiWhiskBoutCaStruc] = itiWhiskBoutCaFrame(1, 0); toc;
                        numSessions = numSessions + 1;
                        itiWhiskBoutCaMouseStruc.sessionNameCell{numSessions} = sessionName;
                        itiWhiskBoutCaMouseStruc.frameRates(numSessions) = itiWhiskBoutCaStruc.frameRate;
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutCa(:,numSessions) = nanmean(itiWhiskBoutCaStruc.itiWhiskBoutCa,1);
                        
                        maxLength = max([size(itiWhiskBoutCaStruc.itiWhiskBoutAngle,1) size(itiWhiskBoutCaStruc.itiWhiskBoutAngle,1)]);
                        
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle(:,numSessions) = nanmean(itiWhiskBoutCaStruc.itiWhiskBoutAngle,1);
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutVar(:,numSessions) = nanmean(itiWhiskBoutCaStruc.itiWhiskBoutVar,1);
                        
                        itiWhiskBoutCaMouseStruc.lockout(numSessions) = itiWhiskBoutCaStruc.lockout;
                        itiWhiskBoutCaMouseStruc.sdThresh(numSessions) = itiWhiskBoutCaStruc.sdThresh;

                        
%                         disp(['Saving itiWhiskBoutCaStruc for ' sessionName]);
%                         save([sessionName '_itiWhiskBoutCaStruc_'  date], 'itiWhiskBoutCaStruc');
                        
                    catch
                        disp(['Failed to process itiWhiskBoutCa for ' sessionName]);
                    end
                    
                else
                    disp(['No whiskerDataStruc for ' sessionName]);
                    
                end  % end IF no previous whiskDataStruc
                
            end  % end IF dayDir entry isdir  (i.e. is a session folder)
        end  % end FOR looking through dayDir
    end  % end IF mouseDir entry isdir  (i.e. is a day folder)
end % end FOR looking through mouseDir

disp('Saving itiWhiskBoutCaMouseStruc');
cd(folderPath);
save(['itiWhiskBoutCaMouseStruc_' mouseName '_' date], 'itiWhiskBoutCaMouseStruc');

% figure; hold on;
% plot(nanmean(itiWhiskBoutCaMouseStruc.itiWhiskBoutCa, 2), 'm');
% plot(nanmean(itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle, 2),'b');
% plot(nanmean(itiWhiskBoutCaMouseStruc.sdThresh, 2), 'g');
% plot(nanmean(itiWhiskBoutCaMouseStruc.unsdThresh, 2), 'r');
% plot(nanmean(itiWhiskBoutCaMouseStruc.fullSessionXcorr, 2), 'c');
% legend('allITIs', 'randRewITIs', 'stimTrials', 'catchTrials', 'fullSession(10x)');
% title([mouseName ' whiskCaXCorrGroup on ' date]);

