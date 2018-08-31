function [groupStruc] = compileFolderCaAvg()



masterFieldnamesDir = ...
    '/home/clay/Documents/Data/2p mouse behavior/masterFieldNamesCaAvg.mat';

load(masterFieldnamesDir);

for fieldNum = 1:length(masterFieldNamesCaAvg)
    groupStruc.(masterFieldNamesCaAvg{fieldNum}) = [];
end

groupStruc.filename = {};

cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;


fileNames = {cageDir.name};

numFiles = 0;

for numFile = 3:length(cageDir)
    
    if strfind(cageDir(numFile).name, 'dendriteBehavStruc')
        
        numFiles = numFiles + 1;
        groupStruc.filename{numFiles} = cageDir(numFile).name;
        load(cageDir(numFile).name); % load dendriteBehavStruc
        
        strucFields = fieldnames(dendriteBehavStruc);
        
        for field = 1:length(strucFields)
            if strfind(strucFields{field}, 'CaAvg')
                
                try
                    fieldInd = find(strcmp(masterFieldNamesCaAvg, strucFields{field}));
                    
                    groupStruc.(masterFieldNamesCaAvg{fieldInd}) = ...
                        [groupStruc.(masterFieldNamesCaAvg{fieldInd}) dendriteBehavStruc.(strucFields{field})];
                catch
                    disp(['Problem processing field: ' strucFields{field}]);
                end
            end
        end
    end
end







