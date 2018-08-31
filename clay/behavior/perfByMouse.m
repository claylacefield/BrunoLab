function perfByMouse(firstDay, lastDay)

% Script to take all files from certain days and put them into "performance
% by mouse" folders

% INPUTS:
% firstDay = first day to copy files from (in standard format for me, i.e.
% '051711')
% lastDay = last day to copy files from
%
% OUTPUT:
% TXT data files and PNG photos for each animal are copied into their
% respective folders in the "performance by mouse" folder


yearFolder = '\\10.112.43.36\Public\clay\mouse behavior\2011\';
% array of all mouse names
mouseNameArr = {'H10' 'H11' 'H12' 'H13' 'H14' 'H20' 'H21' 'H22' 'H24' 'C10' 'C11' 'C13' 'C20' 'C23' 'C30' 'C31' 'C33' 'C34' 'C40' 'C41' 'C42' 'C43' 'C44' 'CE1' 'H20' 'H21' 'H22' 'H24' 'H30' 'H31' 'H32' 'H33' 'H34' 'H40' 'H41' 'H42' 'H43' 'H44'};
go = 0; % variable for whether or not to process a particular day

% dayArr = 0;   % not using these variables in this incarnation
% day = firstDay;

cd(yearFolder);     % go to correct year folder
dayDir = dir;       % and list files in this folder

for k=3:length(dayDir)      % look through all days from the desired year folder
    if strfind(dayDir(k).name, firstDay)    % and start processing with the "firstDay" specified in arguments
        go = 1;
    end

    if go == 1  % don't start processing until you reach the first day desired
        dayFolder = [yearFolder dayDir(k).name];    % build path for this day folder
        cd(dayFolder);  % and go to this location
        currDir = dir;  % and list the files in this folder

        %% LOOK THROUGH ALL FILES IN THE FOLDER FOR THIS DAY
        for i = 3:length(currDir);  % look through all the files from this day
            if length(currDir(i).name) > 3  % if there are enough files in this folder
                for j=1:length(mouseNameArr)    % for all mice in list
                    if strfind(currDir(i).name, mouseNameArr{j});    % see if file is for this animal
                        source = [dayFolder '\' currDir(i).name ];
                        destination = strcat(yearFolder, 'performance by mouse\', mouseNameArr{j}, '\', currDir(i).name);
                        copyfile(source, destination);  % this is the main method for copying the correct mouse files
                    end     % end IF conditional for which animal
                end  % end FOR loop to see which animal file is for
            end     % end IF conditional for whether there are enough files for this day
        end     % end for loop for all files in this day's folder
        
    end  % end IF conditional to see if it should process this day
    
    % and specify to stop processing at end of folder for last day
    if strfind(dayDir(k).name, lastDay)
        go = 0;
    end

end  % end FOR loop to search through all days in year directory