function readTxtEditDataFileArray()

%% so there are two main things I want to do:
% 1.) based upon info in TXT file header, edit dataFileArray
% 2.) based upon dataFileArray fields
%       (mult fields, e.g. animal and lick/lev, soma/dend (layer),
%        program, or rew direction)
%     compile dendriteBehavAnalysis into batch


% script to go through a bunch of sessions, look at TXT file headers, 
% and based upon different features, edit dataFileArray

paramType = 'txt';  % name of the parameter type to look at

colInd = find(strcmp(paramType, dataFileArray{1,:}));


paramValue = 'Cux2';



% select folder to analyze

for rowInd = 1:size(dataFileArray, 1)
    
    tifName = dataFileArray{rowInd, 1};
    animalName = dataFileArray{rowInd, 2}; 
    txtName = dataFileArray{rowInd, 4}; 
    
    
    if ~isempty(strfind(dataFileArray{rowInd, colInd}, paramValue))
        
        
    end
    
    %%
    hz = dataFileArray{rowIndArr(numData), 6};
    
    % find the folder for the dataset and go there
    
    animalName = dataFileArray{rowIndArr(numData), 2};
    mouseFolderInd = find(strcmp(animalName, mouseFolderList));
    cd(mouseFolderList{mouseFolderInd,2});
    tifName = dataFileArray{rowIndArr(numData), 1};
    dayName = tifName(1:10);
    cd(dayName);

    txtFile = load(txtName);

    
end
