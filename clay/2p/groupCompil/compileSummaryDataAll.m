function compileSummaryDataAll(mouseFolderList, summStrucFields)

numBadDays = 1;
badDayCell{1}=date;

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
                    sessName = dayDir(k).name;
                    sessPath = [dayPath sessName '/'];
                    cd(sessPath);
                    try
                        
                        try
                            sessSummName = findLatestFilename('sessSummStruc');
                            disp(['Found previous sessSummStruc for ' sessName ' so loading']);
                            load(sessSummName);
                        catch
                            disp(['Cant find previous sessSummStruc for ' sessName ' so processing']);
                            [sessSummStruc] = calcSummaryData();
                        end
                        
                        
                        numSess = numSess +1;
                        fields = summStrucFields; % fieldnames(sessSummStruc);
                        mouseSummCell{numSess,1} = mouseName;
                        mouseSummCell{numSess,2} = mouseDir(j).name;
                        
                        % had to build in hack in case avgTif and somaDend
                        % not present in sessSummStruc
                        
                        try  % if avgTif and somaDend are present
                            test = sessSummStruc.avgTif;
                            for m = 1:length(fields)
                                field = fields{m};
                                if isempty(strfind(field, 'itiWhiskBoutCaStruc'))
                                    mouseSummCell{numSess,m+2} = sessSummStruc.(field);
                                end
                            end
                        catch % or if not then load from file
                            
                            disp('avgTif and somaDend not in sessSummStruc so loading');
                            
                            try
                                somaDendTifName = findLatestFilename('somaDendTif');
                                load(somaDendTifName);
                                mouseSummCell{numSess,3} = sessSummStruc.(fields{1});
                                mouseSummCell{numSess,4} = sessSummStruc.(fields{2});
                                mouseSummCell{numSess,5} = avgTif;
                                mouseSummCell{numSess,6} = somaDend;
                                
                                for m = 5:length(fields)
                                    field = fields{m};
                                    if isempty(strfind(field, 'itiWhiskBoutCaStruc'))
                                        mouseSummCell{numSess,m+2} = sessSummStruc.(field);
                                    end
                                end
                                
                            catch
                                disp('No avgTif and somaDend');
                            end
                        end
                        
                    catch
                        disp(['Cannot process ' dayDir(k).name]);
                        numBadDays = numBadDays + 1;
                        badDayCell{numBadDays} = sessPath;
                    end
                end % end IF isdir
            end  % end FOR loop for all sessions in day folder
        end % end IF isdir
        
        cd(mouseFolderPath);
        
    end  % end FOR loop for all folders in mouseDir
    
    cd(mouseFolderPath);
    try
    save([mouseName '_mouseSummCell_' date], 'mouseSummCell');
    clear mouseSummCell;
    catch
        disp(['No mouseSummCell for ' mouseName]);
    end
    
end

cd('/home/clay/Documents/Data/2p mouse behavior/');
save(['badDayCell_' date], 'badDayCell');