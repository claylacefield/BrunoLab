function processWhiskerVideoDay(saveMem)


% This is a script to search through all of the days in a directory (e.g.
% motionCorrected/toCorrect) and 

% saveMem variable just changes the way MP4 files are loaded using extractStimFrames, which is
% slower I think, but doesn't take as much RAM


dayPath = uigetdir;
cd(dayPath);

dayDir = dir;

for dayDirInd = 3:length(dayDir)
    
    if dayDir(dayDirInd).isdir
        sessionName = dayDir(dayDirInd).name;
        sessionPath = [dayPath '/' sessionName];
        cd(sessionPath);
        
        sessionDir = dir;
        sessionFilenames = {sessionDir.name};
        
        if isempty(find(cellfun(@length, strfind(sessionFilenames, 'whiskDataStruc')))) && ...
                ~isempty(find(cellfun(@length, strfind(sessionFilenames, 'dendriteBehavStruc'))))...
                ~isempty(find(cellfun(@length, strfind(sessionFilenames, '.measurements'))))
            
            
            try
                [whiskDataStruc] = processWhiskerVideoPS3eye(saveMem);
            catch
                disp(['Failed to process whisker video for ' sessionName]);
            end
            
        else
            disp(['Found previous whiskerDataStruc for ' sessionName]);
            
        end  % end IF no previous whiskDataStruc
        
    end  % end IF dayDir entry isdir  (i.e. is a session folder)
end  % end FOR looking through dayDir



