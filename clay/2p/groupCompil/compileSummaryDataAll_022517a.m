function compileSummaryDataAll(mouseFolderList)




% This is a script to go through all data from a mouseFolderList and
% extract out useful summary data

for i = 1:size(mouseFolderList,1)
    
    mouseName = mouseFolderList{i,1};
    
    mouseFolderPath = mouseFolderList{i,2};
    
    cd(mouseFolderPath);
    
    mouseDir = dir;
    
    numSess = 0;
    
    % go through mouse dir
    
    for j = 1:length(mouseDir)
        
        if mouseDir(j).isdir && ~isempty(strfind(mouseDir(j).name, '201'))
            dayPath = [mouseFolderPath '/' mouseDir(j).name '/'];
            cd(dayPath);
            dayDir = dir;
            for k = 1:length(dayDir)
                if dayDir(k).isdir && ~isempty(strfind(dayDir(k).name, '201'))
                    sessPath = [dayPath dayDir(k).name '/'];
                    cd(sessPath);
                    try
                        [sessSummStruc] = calcSummaryData();
                        numSess = numSess +1;
                        fields = fieldnames(sessSummStruc);
                        mouseSummCell{numSess,1} = mouseName;
                        mouseSummCell{numSess,2} = mouseDir(j).name;
                        for m = 1:length(fields)
                            mouseSummCell{numSess,m+2} = sessSummStruc.(fields{m});
                        end
                        
                    catch
                        disp(['Cannot process ' dayDir(k).name]);
                    end
                end % end IF isdir
            end  % end FOR loop for all sessions in day folder
        end % end IF isdir
        
        cd(mouseFolderPath);
        
    end  % end FOR loop for all folders in mouseDir
    
    cd(mouseFolderPath);
    save([mouseName '_mouseSummCell_' date], 'mouseSummCell');
    
end