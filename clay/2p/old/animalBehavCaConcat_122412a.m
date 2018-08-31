

epochLength = 8*hz+1;
numFiles = 0;
numFields = 0;

animalFolder = uigetdir;
cd(animalFolder);

parentDir = dir;

% for each day in the folder for this animal

for i = 3:length(parentDir)
    
    if isdir([animalFolder '/' parentDir(i).name])
        
        cd([animalFolder '/' parentDir(i).name]);   % go to day folder
        
        % find the dendriteBehavStruc (if it exists)
        
        currDir = dir;
        %fn = fieldnames(currDir);
        
        for j = 3:length(currDir)
            if strfind(currDir(j).name, 'dendriteBehavStruc')
                
                load(currDir(j).name, 'dendriteBehavStruc');
                
                % see if it is at 4Hz
                
                rewardsCaAvg = dendriteBehavStruc.rewardsCaAvg;
                
                if length(rewardsCaAvg) == epochLength   % if it's at a particular framerate
                    a = 1;  % just for testing
                    
                    numFiles = numFiles + 1;
                    
                    % unpack the ca avg variables and concatenate
                    fieldNames = fieldnames(dendriteBehavStruc);
                    
                    for k=1:length(fieldNames)
                       if strfind(dendriteBehavStruc.fieldNames{k}, 'Avg')
                           numFields = numFields + 1;
                           
                           
                       end
                        
                    end
                    
                    
                end
                
                % if so, loop through each avg variable and concatenate
                
                
            end
        end
        
    end
    
end