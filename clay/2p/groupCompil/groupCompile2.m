function [groupStruc2] = groupCompile2(groupStruc, masterFieldNames)

%% USAGE: [groupStruc2] = groupCompile2(groupStruc, masterFieldNames);
% NOTE: masterFieldNames should correspond to whatever type of data struc
% you're compiling, i.e. masterFieldNamesCaAvg or masterFieldNamesEventHist

animalNames = fields(groupStruc);
numAnimals = length(animalNames);

dayRangeArr = [ 0 0 0 0 0 0 20 20 20 20 20];


for field = 1:length(masterFieldNames)
    try
        groupStruc2.(masterFieldNames{field}) = [];
    catch
        %dbs.(masterFieldNamesCaAvg{field}) = [];
    end
    
end
    

for animal = 1:numAnimals
    
    animalStruc = groupStruc.(animalNames{animal});
    
    
    for field = 1:length(masterFieldNames)
        try
            animalFieldData = animalStruc.(masterFieldNames{field});
            groupStruc2.(masterFieldNames{field}) = [groupStruc2.(masterFieldNames{field}) nanmean(animalFieldData(:,1:min(dayRangeArr(animal), size(animalFieldData, 2))),2)];
            clear animalFieldData;
        catch
            %dbs.(masterFieldNamesCaAvg{field}) = [];
        end

    end
    
    clear animalStruc;
    
end

group2.dayRangeArr = dayRangeArr;
