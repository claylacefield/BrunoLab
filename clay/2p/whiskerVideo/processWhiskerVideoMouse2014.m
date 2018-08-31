function processWhiskerVideoMouse2014(toProcessNew)


% This is a script to search through all of the days in a mouse directory
% with whisker video files using PhotonFocus high speed camera in 2014,
% extract out the files of whisker data (whiskMeasStruc and whFrTimeStruc)
% and to save a whiskDataStruc (for use in previous analyses like I did for
% PS3eye data)


folderPath = uigetdir;
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
                
                if isempty(find(cellfun(@length, strfind(sessionFilenames, 'whiskDataStruc'))))
                    
                    % toProcess whisker-related data (if not already)
                    if toProcessNew == 1 ...
                            && ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'dendriteBehavStruc'))))...
                            && ~isempty(find(cellfun(@length, strfind(sessionFilenames, '.mp4'))))...
                            && ~isempty(find(cellfun(@length, strfind(sessionFilenames, '.measurements'))))
                        
                        try
                            filename = sessionDir(find(cellfun(@length, strfind(sessionFilenames, '.mp4')))).name;
                            
                            if isempty(find(cellfun(@length, strfind(sessionFilenames, 'whFrTimeStruc'))))
                                dbsName = findLatestFilename('dendriteBehavStruc');
                                load(dbsName);
                                saveMem = 1;
                                [frTimes, frameRate, frTopAv,whFrTimeStruc] = extractStimFramesPhotFoc(filename, dendriteBehavStruc, saveMem);
                            end
                            
                            if isempty(find(cellfun(@length, strfind(sessionFilenames, 'whiskMeasStruc'))))
                                basename = filename(1:strfind(filename, '.mp4')-1);
                                lengthThresh = 100;
                                [meanAngle, medianAngle, totalFr, whiskMeasStruc] = extractBestWhiskerAnglesPhotFoc(basename, lengthThresh);
                            end
                            
                        catch
                            disp(['Cant process new whisk data for ' sessionName]);
                        end
                        
                    end
                    %disp(['Cant find whiskerStruc for ' sessionName]);
                    
                    if ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'whFrTimeStruc'))))...
                            && ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'whiskMeasStruc'))))
                        
                        try
                            [whiskDataStruc] = convertOldWhiskData2();
                            disp(['Processed whisker video for ' sessionName]);
                        catch
                            disp(['Failed to process whisker video for ' sessionName]);
                        end
                        
                    else
                        disp(['Cant find/make relevant strucs for whiskDataStruc for ' sessionName]);
                    end
                    
                else
                    disp(['Found previous whiskDataStruc for ' sessionName ' so not repeating']);
                    
                end  % end IF no previous whiskDataStruc
                
            end  % end IF dayDir entry isdir  (i.e. is a session folder)
        end  % end FOR looking through dayDir
    end  % end IF mouseDir entry isdir  (i.e. is a day folder)
end % end FOR looking through mouseDir



