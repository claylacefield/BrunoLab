function dendriteBehavAnalysisMouseList(mouseFolderList)




% This is a script to go through all data from a mouseFolderList and
% extract out useful summary data

for i = 1:size(mouseFolderList,1)
    
    mouseName = mouseFolderList{i,1};
    
    mouseFolderPath = mouseFolderList{i,2};
    
    cd(mouseFolderPath);
    
    mouseDir = dir;
    
    numSess = 0;
    
    % go through mouse dir
    
    for j = 1:length(mouseDir)
        
        if mouseDir(j).isdir && ~isempty(strfind(mouseDir(j).name, '201'))
            dayPath = [mouseFolderPath '/' mouseDir(j).name '/'];
            cd(dayPath);
            dayDir = dir;
            for k = 1:length(dayDir)
                if dayDir(k).isdir && ~isempty(strfind(dayDir(k).name, '201'))
                    sessPath = [dayPath dayDir(k).name '/'];
                    cd(sessPath);
                    try
                        tifName = [dayDir(k).name '.tif'];
                        seg = 1; toProcess = 1;
                        [dendriteBehavStruc] = dendriteBehavAnalysisNameSeg(tifName, dayPath, seg, toProcess);
                    catch
                        disp(['Cannot process ' dayDir(k).name]);
                    end
                end % end IF isdir
            end  % end FOR loop for all sessions in day folder
        end % end IF isdir
        
        cd(mouseFolderPath);
        
    end  % end FOR loop for all folders in mouseDir
    
    cd(mouseFolderPath);
    
end