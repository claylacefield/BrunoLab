function [batchDendStruc2hz, batchDendStruc4hz, batchDendStruc8hz] = compileSimilarData(mouseFolderList, masterFieldNamesCaAvg, dataFileArray)

% 121514 writing script to compile all data from sepChoice



nans2(1:17) = NaN;
nans4(1:33) = NaN;
nans8(1:65) = NaN;

num2hzFiles = 0;
num4hzFiles = 0;
num8hzFiles = 0;

for field = 1:length(masterFieldNamesCaAvg)
    try
        batchDendStruc2hz.(masterFieldNamesCaAvg{field}) = [];
        batchDendStruc4hz.(masterFieldNamesCaAvg{field}) = [];
        batchDendStruc8hz.(masterFieldNamesCaAvg{field}) = [];
        %batchEventHistStruc2hz.(masterFieldNamesEventHist{field}) = [];
        %batchEventHistStruc4hz.(masterFieldNamesEventHist{field}) = [];
        %batchEventHistStruc8hz.(masterFieldNamesEventHist{field}) = [];
    catch
        %dbs.(masterFieldNamesCa{field}) = [];
    end
    
end



% find sepChoice data in dataFileArray
rowIndArr = find(strcmp('sepChoice', dataFileArray(:,8)));

% NOTE: want to make this work for multiple filters too

% go through all the sepChoice datasets
for numData = 1:length(rowIndArr)
    
    hz = dataFileArray{rowIndArr(numData), 6};
    
    % find the folder for the dataset and go there
    
    animalName = dataFileArray{rowIndArr(numData), 2};
    mouseFolderInd = find(strcmp(animalName, mouseFolderList));
    cd(mouseFolderList{mouseFolderInd,2});
    tifName = dataFileArray{rowIndArr(numData), 1};
    dayName = tifName(1:10);
    cd(dayName);
    cd(tifName(1:14));
    tifDir = dir;
    
    % now find dendriteBehavStruc and compile all fields
    
    % find all dendriteBehavStruc in tifDir
    
    dendStrucNum = 0;
    
    for numFile = 1:length(tifDir)
        
        if ~isempty(strfind(tifDir(numFile).name, 'dendriteBehavStruc')) %&& firstFile2 == 0
            dendStrucNum = dendStrucNum + 1;
            dendBehavStrucNum(dendStrucNum) = numFile;
        end
        
    end
    
    % find latest dendriteBehavStruc and load
    [newestDendDatenum, newestDendInd] = max([tifDir(dendBehavStrucNum).datenum]);
    
    inStruc = load(tifDir(dendBehavStrucNum(newestDendInd)).name);
    fieldNamesEvSt = fieldnames(inStruc);
    dendriteBehavStruc = inStruc.(fieldNamesEvSt{1});
    
    clear dendBehavStrucNum newestDendInd fieldNamesEvSt inStruc;
    
    
    %% Fieldnames loop
    % this loop unpacks all the structure fields into variables of the same name
    
    fieldNames = masterFieldNamesCaAvg;
    %fieldNames2 = masterFieldNamesEventHist;
    
    for field = 1:length(fieldNames)
        
        try
            sessionFieldData = dendriteBehavStruc.(fieldNames{field});
            %sessionEventData = eventHistBehavStruc.(fieldNames2{field});
            processField = 1;
        catch
            if hz == 2
                batchDendStruc2hz.(fieldNames{field}) = [batchDendStruc2hz.(fieldNames{field}) nans2'];
                %batchEventHistStruc2hz.(fieldNames2{field}) = [batchEventHistStruc2hz.(fieldNames2{field}) nans2ev'];
                %num2hzFiles = num2hzFiles + 1;
            elseif hz == 4
                batchDendStruc4hz.(fieldNames{field}) = [batchDendStruc4hz.(fieldNames{field}) nans4'];
                %batchEventHistStruc4hz.(fieldNames2{field}) = [batchEventHistStruc4hz.(fieldNames2{field}) nans4ev'];
                %num4hzFiles = num4hzFiles + 1;
            elseif hz == 8
                batchDendStruc8hz.(fieldNames{field}) = [batchDendStruc8hz.(fieldNames{field}) nans8'];
                %batchEventHistStruc8hz.(fieldNames2{field}) = [batchEventHistStruc8hz.(fieldNames2{field}) nans8ev'];
                %num8hzFiles = num8hzFiles + 1;
            end % end IF for concat into struc at diff fps
            processField = 0;
        end
        
        if  processField == 1 %&& ~isempty(dendriteBehavStruc.(fieldNames{field}))
            
            %sessionFieldData = dendriteBehavStruc.(fieldNames{field});
            
            % concatenate average into batch struc for each
            % framerate
            if hz == 2
                batchDendStruc2hz.(fieldNames{field}) = [batchDendStruc2hz.(fieldNames{field}) sessionFieldData];
                %batchEventHistStruc2hz.(fieldNames2{field}) = [batchEventHistStruc2hz.(fieldNames2{field}) sessionEventData];
                %num2hzFiles = num2hzFiles + 1;
            elseif hz == 4
                batchDendStruc4hz.(fieldNames{field}) = [batchDendStruc4hz.(fieldNames{field}) sessionFieldData];
                %batchEventHistStruc4hz.(fieldNames2{field}) = [batchEventHistStruc4hz.(fieldNames2{field}) sessionEventData];
                %num4hzFiles = num4hzFiles + 1;
            elseif hz == 8
                batchDendStruc8hz.(fieldNames{field}) = [batchDendStruc8hz.(fieldNames{field}) sessionFieldData];
                %batchEventHistStruc8hz.(fieldNames2{field}) = [batchEventHistStruc8hz.(fieldNames2{field}) sessionEventData];
                %num8hzFiles = num8hzFiles + 1;
            end
            
            clear sessionFieldData; % sessionEventData;
            
            % end
            
        end     % end IF for processing this field
    end     % end FOR loop for all fieldnames
    
end  % END FOR loop for all sepChoice sessions