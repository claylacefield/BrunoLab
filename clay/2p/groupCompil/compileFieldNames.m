

% these loops just create new fieldNames from old
for i = 1:length(masterFieldNames2)
    fieldName = masterFieldNames2{i};
    masterFieldNamesCa{i} = fieldName(1:(strfind(fieldName, 'Ca')+1));
    
end

masterFieldNamesCa = masterFieldNamesCa';


for field = 1:length(masterFieldNamesCa)
    masterFieldNamesCaAvg{2*field-1} = masterFieldNamesCa{field};    
    masterFieldNamesCaAvg{2*field}= [masterFieldNamesCa{field} 'Avg'];
    
end

masterFieldNamesCaAvg = masterFieldNamesCaAvg';

% 072714 for event data (whisker contacts)
for field = 1:length(masterFieldNamesCaAvg)
    caAvgName = masterFieldNamesCaAvg{field};
    masterFieldNamesEventHist{field}= [caAvgName(1:strfind(caAvgName, 'CaAvg')-1) 'EventHist'];
end

masterFieldNamesEventHist = masterFieldNamesEventHist';

% build output struc with all possible fields
for field = 1:length(masterFieldNamesCaAvg)
    groupSelStruc.(masterFieldNamesCaAvg{field}) = [];
end

% append fields for each dendBehavStruc (if present, else skip)
for field = 1:length(masterFieldNamesCaAvg)
    try
        groupSelStruc.(masterFieldNamesCaAvg{field}) = [groupSelStruc.(masterFieldNamesCaAvg{field}) dendriteBehavStruc.(masterFieldNamesCaAvg{field})];
    catch
        %dbs.(masterFieldNamesCaAvg{field}) = [];
    end
    
end
