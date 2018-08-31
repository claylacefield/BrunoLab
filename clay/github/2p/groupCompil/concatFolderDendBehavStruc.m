function [batchDendStruc] = concatFolderDendBehavStruc(masterFieldNamesCaAvg)


% script to take all dendriteBehavStruc in a folder (e.g. grouped
% by some parameter, such as stage1) and concatenate all events

pathname = uigetdir;

cd(pathname);


for masterField = 1:length(masterFieldNamesCaAvg)
    
    batchDendStruc.(masterFieldNamesCaAvg{masterField}) = [];
    
end

currDir = dir;

for numFile = 1:length(currDir)
    
    if ~isempty(strfind(currDir(numFile).name, 'dendriteBehavStruc'))
        
        load(currDir(numFile).name);
        
        fieldNames = fieldnames(dendriteBehavStruc);
        
        
        
        for field = 1:length(fieldNames)
            try
                batchDendStruc.(fieldNames{field}) = [batchDendStruc.(fieldNames{field}) dendriteBehavStruc.(fieldNames{field})];
            catch
                disp(['Problem with field ' fieldNames{field}]);
            end
        end
        
        
        
    end
    
end
