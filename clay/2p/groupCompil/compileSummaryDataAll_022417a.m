function compileSummaryDataAll(mouseFolderList)




% This is a script to go through all data from a mouseFolderList and
% extract out useful summary data

for i = 1:size(mouseFolderList,1)
    
    mouseName = mouseFolderList{i,1};
    
    mouseFolderPath = mouseFolderList{i,2};
    
    cd(mouseFolderPath);
    
    mouseDir = dir;
    
    % go through mouse dir
    
    for j = 1:length(mouseDir)
        
        if mouseDir(j).isdir && ~isempty(strfind(mouseDir(j).name, '201'))
            cd(mouseDir(j).name);
            dayDir = dir;
            for k = 1:length(dayDir)
                if dayDir(k).isdir && ~isempty(strfind(dayDir(k).name, '201'))
                    cd(dayDir(k).name);
                    [sessSummStruc] = calcSummaryData();
                end
            end
        end % end IF isdir
    end  % end FOR loop for all folders in mouseDir
    
end