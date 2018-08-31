function [cageBatchStruc] = cageBatchAvg(batchStruc, numSessions, toPlot)


% This is a script to take the latest batchDendStrucs for all animals in a
% cage and to take the average over some number of days for all animals

numAnimal = 0;


cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

cageBatchStruc.folder = cageFolder;

for mouse = 3:length(cageDir)
    
    if cageDir(mouse).isdir
        
        % go to the animal folder
        
        numAnimal = numAnimal + 1;
        
        mouseName = cageDir(mouse).name;      % select the animal folder to analyze
        mouseFolder = [cageFolder '/' mouseName];
        cd(mouseFolder);    % go to the mouse folder
        
        mouseDir = dir;
        
        % and look for the latest batch struc (of whatever type)
        mouseDirName = {mouseDir.name};     % make cell array of filenames
        batchFileInd = find(strncmp(mouseDirName, batchStruc, 17)); 
        batchFileDates = [mouseDir(batchFileInd).datenum];
        [batchDate, newestBatchFileInd] = max(batchFileDates); 
        newestBatchFile = batchFileInd(newestBatchFileInd);
        load(mouseDir(newestBatchFile).name);
        eval(['batchDendStruc = ' batchStruc ';']);
        
        % look for latest batchDendStruc
%         for file = 3:length(mouseDir)
%             
%             if strfind(mouseDir(file).name, 'batchDendStruc4hz')
%                 
%                 batchDate = mouseDir(file).datenum;
%                 
%                 % load in the latest batchDendStruc
%                 
%                 batchDendStruc = load(mouseDir(file).name);
%                 
%             end
%             
%         end
        
        fieldNames = {};
        
        fieldNames = fieldnames(batchDendStruc);
        
        for field = 1:length(fieldNames)
            
            if ~isempty(batchDendStruc.(fieldNames{field}))
                
                eventAvg = [];
                eventDays = [];
            
            try
                
                eventName = fieldNames{field};
                
                eventDays = batchDendStruc.(fieldNames{field});
                
                maxDay = min(numSessions, size(eventDays, 2)); % take a max of 20 behav. sessions
                eventDays = eventDays(:,1:maxDay);
                eventAvg = mean(eventDays, 2);  % and take the average for these
                
                eval( [eventName 'Avg(:, ' num2str(numAnimal) ') = eventAvg;']);
                
            catch
                eventName = fieldNames{field};
                eval( [eventName 'Avg(:, ' num2str(numAnimal) ') = zeros(8001,1);']);
                disp(['something went wrong with ' eventName]);
            end
            
            else
                eventName = fieldNames{field};
                eval( [eventName 'Avg(:, ' num2str(numAnimal) ') = zeros(8001,1);']);
                disp(['something went wrong with ' eventName]);
            end
            
        end     % end FOR loop of all fields in structure
        
        %end     % end IF cond for finding batchDendStrucs
        
        %end     % end FOR loop for all files in animal directory (to find batch)
        clear batchDendStruc;
        
    end     % end IF cond for isdir
    
end     % end FOR loop for all animals in cage folder



% now put everything together into an output structure

for field = 1:length(fieldNames)
    
    try
        eventName = fieldNames{field};
        
        eval( ['cageBatchStruc.' eventName ' = ' eventName 'Avg;']);
        
    catch
    end
    
end


if toPlot

rewTime1CaAvgAvg = mean(cageBatchStruc.rewTime1CaAvg,2);
rewTime1CaAvgSEM = std(cageBatchStruc.rewTime1CaAvg,0,2)/sqrt(size(cageBatchStruc.rewTime1CaAvg,2));
corrRewFirstContactTimes1CaAvgAvg = mean(cageBatchStruc.corrRewFirstContactTimes1CaAvg,2);
corrRewFirstContactTimes1CaAvgSEM = std(cageBatchStruc.corrRewFirstContactTimes1CaAvg,0,2)/sqrt(size(cageBatchStruc.corrRewFirstContactTimes1CaAvg,2));
incorrRewFirstContactTimes1CaAvgAvg = mean(cageBatchStruc.incorrRewFirstContactTimes1CaAvg,2);
incorrRewFirstContactTimes1CaAvgSEM = std(cageBatchStruc.incorrRewFirstContactTimes1CaAvg,0,2)/sqrt(size(cageBatchStruc.incorrRewFirstContactTimes1CaAvg,2));

try
rewTime5CaAvgAvg = mean(cageBatchStruc.rewTime5CaAvg,2);
rewTime5CaAvgSEM = std(cageBatchStruc.rewTime5CaAvg,0,2)/sqrt(size(cageBatchStruc.rewTime5CaAvg,2));
catch
end

try
rewTime6CaAvgAvg = mean(cageBatchStruc.rewTime6CaAvg,2);
rewTime6CaAvgSEM = std(cageBatchStruc.rewTime6CaAvg,0,2)/sqrt(size(cageBatchStruc.rewTime6CaAvg,2));
catch
end

% now plot some stuff out

figure; 
plot(rewTime1CaAvgAvg); 
errorbar(rewTime1CaAvgAvg, rewTime1CaAvgSEM);
hold on;
plot(corrRewFirstContactTimes1CaAvgAvg,'g');
errorbar(corrRewFirstContactTimes1CaAvgAvg, corrRewFirstContactTimes1CaAvgSEM,'g');
plot(incorrRewFirstContactTimes1CaAvgAvg,'r');
errorbar(incorrRewFirstContactTimes1CaAvgAvg, incorrRewFirstContactTimes1CaAvgSEM,'r');

try
plot(rewTime5CaAvgAvg,'y');
errorbar(rewTime5CaAvgAvg, rewTime5CaAvgSEM,'y');
catch
end

try
plot(rewTime6CaAvgAvg, 'm');
errorbar(rewTime6CaAvgAvg, rewTime6CaAvgSEM, 'm');
catch
end

end
