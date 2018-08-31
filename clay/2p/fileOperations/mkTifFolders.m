function mkTifFolders()

% moves .tif files into folders of the same name, for the purposes of
% Patrick's batch motion correction

parentFolder = uigetdir;      % select the animal folder to analyze
cd(parentFolder);   % go to there
%[pathname animalName] = fileparts(parentFolder);
parentDir = dir;    % see what files/folders are present

for i = 3:length(parentDir) % go through all of them
    cd(parentFolder);
    if parentDir(i).isdir  % and if it is a folder (i.e. a day folder)
        dayFolder = parentDir(i).name;
        cd(dayFolder);  % go there
        dayDir = dir;   % and see what files are present
        for j = 3:length(dayDir)
            if strfind(dayDir(j).name, '.tif')  % and if it finds a .tif
                filename = dayDir(j).name;
                basename = filename(1:(strfind(filename, '.tif')-1));
                mkdir(basename);  % make a folder with this name
                
                source = [parentFolder '/' dayFolder '/' filename];
                dest = [parentFolder '/' dayFolder '/' basename '/' filename];
                movefile(source, dest);     % and put the tif into the folder
                
            end
        end
        
        
    end
    
    
end