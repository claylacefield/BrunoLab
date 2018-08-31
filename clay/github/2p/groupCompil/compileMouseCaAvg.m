function [mouseStruc] = compileMouseCaAvg(programTag)

% This is a function to compile all dendriteBehavStrucs from a single mouse
% for a particular behavioral program type (specified in programTag)

mouseStruc.programTag = programTag;

% load in event fieldnames for output struc
masterFieldnamesDir = ...
    '/home/clay/Documents/Data/2p mouse behavior/masterFieldNamesCaAvg.mat';

load(masterFieldnamesDir);

for fieldNum = 1:length(masterFieldNamesCaAvg)
    mouseStruc.(masterFieldNamesCaAvg{fieldNum}) = [];
end

mouseStruc.filename = {};
mouseStruc.programName = {};

% select mouse folder
mouseFolder = uigetdir;      % select the animal folder to analyze
cd(mouseFolder);

mouseName = mouseFolder(strfind(mouseFolder, '/mouse')+1:end)
mouseStruc.mouseName = mouseName;

mouseDir = dir;
%fileNames = {mouseDir.name};

numFiles = 0;

for day = 3:length(mouseDir)  % go thru all days in mouseDir
    
    if mouseDir(day).isdir  % make sure this file is indeed a dir
        
        cd(mouseDir(day).name); % go to that day folder
        
        dayDir = dir;
        dayDirFilenames = {dayDir.name};
        
        for session = 3:length(dayDir)
            
            if dayDir(session).isdir
                
                cd(dayDir(session).name);
                
                sessionDir = dir;
                
                sessionDirFilenames = {sessionDir.name};
                
                if ~isempty(find(cellfun(@length, strfind(sessionDirFilenames, 'dendriteBehavStruc'))))
                    
                    % check to see if the program name is a particular type
                    txtFilename = sessionDirFilenames{find(cellfun(@length, strfind(sessionDirFilenames, '.txt')))};
                    programName = readArduinoProgramName(txtFilename);
                    
                    % only compile data from sessions with a particular behavioral
                    % program (e.g. normal vs. sepChoice)
                    if strfind(programName, programTag)
                        
                        numFiles = numFiles + 1;
                        
                        mouseStruc.programName{numFiles} = programName;
                        
                        % load latest dendriteBehavStruc
                        latestDbsName = findLatestFilename('dendriteBehavStruc');
                        disp(['Loading in ' latestDbsName]); tic;
                        load(latestDbsName); toc;
                        mouseStruc.filename{numFiles} = latestDbsName;
                        
                        strucFields = fieldnames(dendriteBehavStruc);
                        
                        for field = 1:length(masterFieldNamesCaAvg)
                            %if strfind(strucFields{field}, 'CaAvg')
                            
                            try
                                fieldInd = find(strcmp(strucFields, masterFieldNamesCaAvg{field}));
                                
                                if size(dendriteBehavStruc.(strucFields{fieldInd}),1) == 33
                                    mouseStruc.(masterFieldNamesCaAvg{field}) = ...
                                        [mouseStruc.(masterFieldNamesCaAvg{field}) dendriteBehavStruc.(strucFields{fieldInd})];
                                end
                            catch
                                %disp(['cant find field: ' masterFieldNamesCaAvg{field} ', so replacing with NaNs']);
                                mouseStruc.(masterFieldNamesCaAvg{field}) = ...
                                    [mouseStruc.(masterFieldNamesCaAvg{field}) nan(33,1)];
                            end
                            %end
                        end  % end FOR loop for all fields in masterFieldNames
                        
                    end  % end IF for particular behavioral program name
                    
                end   % end IF there is a dendriteBehavStruc
                
                cd ..;
                
            end % dayDir(session).isdir
        end  % end FOR all sessions in dayDir
        
    end % end if isdir
    
    cd(mouseFolder);
end    % end FOR all files in mouse folder


save(['mouseStruc_' mouseName '_' date], 'mouseStruc');






