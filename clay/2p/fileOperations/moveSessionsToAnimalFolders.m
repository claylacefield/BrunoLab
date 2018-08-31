function moveSessionsToAnimalFolders(mouseFolderList)


% This is a script to search through all of the days in a directory (e.g.
% motionCorrected/toCorrect) and move all of the sessions into the correct
% animal folder
% 1. go to day folder of unsorted sessions, go through sessions
% 2. see which animal it's from
% 3. move the session to the correct animal folder (but must create a day
% folder for this first, if it doesn't already exist)
% NOTE: this works for new data where all relevant files are already in
% session folder
% tangential NOTE: I think possibly for the new whisker video data, I
% should go ahead and extract the frame times while they're still in the
% original directory

mouseNames = mouseFolderList(:,1);


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
                
                sessionDirNames = {sessionDir.name};
                
                sessMouseInd = find(cellfun(@length, strfind(sessionDirNames, '_mouse')));
                
                if ~isempty(sessMouseInd)
                exampFilename = sessionDir(sessMouseInd(2)).name;
                mouseName = exampFilename(strfind(exampFilename, 'mouse')+5 : strfind(exampFilename, '.')-2);
                
                mouseListInd = find(cellfun(@length, strfind(mouseNames, mouseName)));
                mousePath = mouseFolderList{mouseListInd, 2};
                cd .. ;
                destPath = [mousePath '/' dayName];
                mkdir(destPath);
                
                disp(['Moving ' sessionPath]);
                disp('to');
                disp(destPath);
                disp(' ');
                
                tic;
                movefile(sessionPath, destPath); toc;
                
                else
                    disp(['Cannot move ' sessionName ' because no behav folders.']);
                end
            end  % end IF dayDir entry isdir  (i.e. is a session folder)
        end  % end FOR looking through dayDir
    end  % end IF mouseDir entry isdir  (i.e. is a day folder)
end % end FOR looking through mouseDir



