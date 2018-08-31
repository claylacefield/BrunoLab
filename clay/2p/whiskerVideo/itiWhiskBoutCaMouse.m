function [itiWhiskBoutCaMouseStruc] = itiWhiskBoutCaMouse(toPlotSess)


% This is a script to search through all of the days in a directory (e.g.
% motionCorrected/toCorrect) and 


itiWhiskBoutCaMouseStruc.itiWhiskBoutCa = [];
itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle = [];
itiWhiskBoutCaMouseStruc.itiWhiskBoutVar = [];

itiWhiskBoutCaMouseStruc.rewItiWhiskBoutCa = [];
itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle = [];
itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVar = [];

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
                    
                    %try
                    
                    disp(['Processing itiWhiskBoutCa for ' sessionName]); tic;
                        [itiWhiskBoutCaStruc] = itiWhiskBoutCaFrame(1, toPlotSess); toc;
                        numSessions = numSessions + 1;
                        itiWhiskBoutCaMouseStruc.sessionNameCell{numSessions} = sessionName;
                        itiWhiskBoutCaMouseStruc.frameRates(numSessions) = itiWhiskBoutCaStruc.frameRate;
                        
                        % concatenate calcium from each session
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutCa = [itiWhiskBoutCaMouseStruc.itiWhiskBoutCa itiWhiskBoutCaStruc.itiWhiskBoutCa];
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutCaAvg(:,numSessions) = mean(itiWhiskBoutCaStruc.itiWhiskBoutCa,2);
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutCaCell{numSessions} = itiWhiskBoutCaStruc.itiWhiskBoutCa;
                        
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutCa = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutCa itiWhiskBoutCaStruc.rewItiWhiskBoutCa];
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutCaAvg(:,numSessions) = mean(itiWhiskBoutCaStruc.rewItiWhiskBoutCa,2);
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutCaCell{numSessions} = itiWhiskBoutCaStruc.rewItiWhiskBoutCa;
                        
                        
                        % for whisker angle, must adjust lengths (because
                        % they're not always the same between sessions)
                        
                        maxLength = max([size(itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle,1) size(itiWhiskBoutCaStruc.itiWhiskBoutAngle,1)]);
                        
                        % new angles/vars
                        itiBoutAngle = itiWhiskBoutCaStruc.itiWhiskBoutAngle;
                        itiBoutVar = itiWhiskBoutCaStruc.itiWhiskBoutVar;
                        
                        rewItiBoutAngle = itiWhiskBoutCaStruc.rewItiWhiskBoutAngle;
                        rewItiBoutVar = itiWhiskBoutCaStruc.rewItiWhiskBoutVar;
                        
                        % for whisker angle vars, pad the shorter with the longer
                        lenDiff = size(itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle,1) - size(itiBoutAngle,1);
                        lenDiff2 = size(itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle,1) - size(rewItiBoutAngle,1);
                        
                        if numSessions ~= 1
                        if lenDiff > 1 % if new angles less than old angles, pad with zeros (should probably pad with mean)
                            itiBoutAngle = [itiBoutAngle; zeros(lenDiff, size(itiBoutAngle,2))];
                            itiBoutVar = [itiBoutVar; zeros(lenDiff, size(itiBoutVar,2))];
                            rewItiBoutAngle = [rewItiBoutAngle; zeros(lenDiff2, size(rewItiBoutAngle,2))];
                            rewItiBoutVar = [rewItiBoutVar; zeros(lenDiff2, size(rewItiBoutVar,2))];
                            
                        elseif lenDiff < 1  % or if length(newAngles) > old angles, then pad old
                            itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle = [itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle; zeros(abs(lenDiff), size(itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle,2))];
                            itiWhiskBoutCaMouseStruc.itiWhiskBoutVar = [itiWhiskBoutCaMouseStruc.itiWhiskBoutVar; zeros(abs(lenDiff), size(itiWhiskBoutCaMouseStruc.itiWhiskBoutVar,2))];
                            itiWhiskBoutCaMouseStruc.itiWhiskBoutAngleAvg = [itiWhiskBoutCaMouseStruc.itiWhiskBoutAngleAvg; zeros(abs(lenDiff), size(itiWhiskBoutCaMouseStruc.itiWhiskBoutAngleAvg,2))];
                            itiWhiskBoutCaMouseStruc.itiWhiskBoutVarAvg = [itiWhiskBoutCaMouseStruc.itiWhiskBoutVarAvg; zeros(abs(lenDiff), size(itiWhiskBoutCaMouseStruc.itiWhiskBoutVarAvg,2))];
                            
                            itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle; zeros(abs(lenDiff2), size(itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle,2))];
                            itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVar = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVar; zeros(abs(lenDiff2), size(itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVar,2))];
                            itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngleAvg = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngleAvg; zeros(abs(lenDiff2), size(itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngleAvg,2))];
                            itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVarAvg = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVarAvg; zeros(abs(lenDiff2), size(itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVarAvg,2))];
                        end
                        end
                        
                        % and concatenate into output structure
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle = [itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle itiBoutAngle];
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutAngleAvg(:,numSessions) = nanmean(itiBoutAngle,2);
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutAngleCell{numSessions} = itiBoutAngle;
                        
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutVar = [itiWhiskBoutCaMouseStruc.itiWhiskBoutVar itiBoutVar];
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutVarAvg(:,numSessions) = nanmean(itiBoutVar,2);
                        itiWhiskBoutCaMouseStruc.itiWhiskBoutVarCell{numSessions} = itiBoutVar;
                        
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngle rewItiBoutAngle];
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngleAvg(:,numSessions) = nanmean(rewItiBoutAngle,2);
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutAngleCell{numSessions} = rewItiBoutAngle;
                        
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVar = [itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVar rewItiBoutVar];
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVarAvg(:,numSessions) = nanmean(rewItiBoutVar,2);
                        itiWhiskBoutCaMouseStruc.rewItiWhiskBoutVarCell{numSessions} = rewItiBoutVar;
                        
                        itiWhiskBoutCaMouseStruc.lockout(numSessions) = itiWhiskBoutCaStruc.params.lockout;
                        itiWhiskBoutCaMouseStruc.sdThresh(numSessions) = itiWhiskBoutCaStruc.params.sdThresh;
                        itiWhiskBoutCaMouseStruc.params = itiWhiskBoutCaStruc.params;
                        
                        
%                         disp(['Saving itiWhiskBoutCaStruc for ' sessionName]);
%                         save([sessionName '_itiWhiskBoutCaStruc_'  date], 'itiWhiskBoutCaStruc');
                        
                    %catch
                        %disp(['Failed to process itiWhiskBoutCa for ' sessionName]);
                    %end
                    
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



plotItiWhiskBoutCaGroup(itiWhiskBoutCaMouseStruc);
title([mouseName ' itiWhiskBoutCaMouseStruc on ' date]);
