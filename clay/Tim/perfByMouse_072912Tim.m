function perfByMouse_072912Tim(firstDay, lastDay)

% Script to take all files from certain days and put them into "performance
% by mouse" folders


yearFolder = '\\10.112.43.36\Public\clay\mouse behavior\2012\';
% array for all mice
mouseNameArr = {'H10' 'H11' 'H12' 'H13' 'H14' 'H20' 'H21' 'H22' 'H24' 'C10' 'C11' 'C13' 'C20' 'C23' 'C30' 'C31' 'C33' 'C34' 'C40' 'C41' 'C42' 'C43' 'C44' 'CE1' 'H20' 'H21' 'H22' 'H24' 'H30' 'H31' 'H32' 'H33' 'H34' 'H40' 'H41' 'H42' 'H43' 'H44' 'H50' 'H51' 'H52' 'H53' 'H54'};
go = 0;

% dayArr = 0;   % not using these variables in this incarnation
% day = firstDay;


cd(yearFolder);     % go to correct year folder
dayDir = dir;

for k=3:length(dayDir)
    if strfind(dayDir(k).name,'020112')
        go = 1;
    end

    if go == 1  % don't start processing until you reach the first day desired
        dayFolder = [yearFolder dayDir(k).name];

        cd(dayFolder);
        currDir = dir;

        %% LOOK THROUGH ALL FILES IN THE FOLDER FOR THIS DAY
        for i = 3:length(currDir);  % look through all the files from this day
            if length(currDir(i).name) > 3  % if there are enough files in this folder
                for j=1:length(mouseNameArr)    % for all mice in list
                    if strfind(currDir(i).name, mouseNameArr{j});    % see if file is for this animal
                        source = [dayFolder '\' currDir(i).name ];
                        destination = strcat(yearFolder, 'performance by mouse\', mouseNameArr{j}, '\', currDir(i).name);
                        copyfile(source, destination);
                    end     % end IF conditional for which animal
                end  % end FOR loop to see which animal file is for
            end     % end IF conditional for whether there are enough files for this day
        end     % end for loop for all files in this day's folder
    end  % end IF conditional to see if it should process this day

    if strfind(dayDir(k).name, '072812')
        go = 0;
    end

end  % end FOR loop to search through all days in directory