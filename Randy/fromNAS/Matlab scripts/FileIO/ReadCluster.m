function cluster = ReadCluster(filename, searchOtherDrives)
% READCLUSTER Read a cluster file.
% READCLUSTER(FILENAME), where FILENAME is a string specifying a file,
% returns an array of timestamps and trial information.
% Returns NaN if user cancels or file not found.
% Randy Bruno, May 2003

if (nargin==0)
   [filename pathname] = uigetfile('*.cluster?', 'Select a cluster file to read');
   filename = fullfile(pathname, filename);
end

if nargin < 2
    searchOtherDrives = false;
end

if filename & ~exist(filename, 'file') & searchOtherDrives
    filename = ['F' filename(2:end)];
    if ~exist(filename, 'file')
        filename = ['G' filename(2:end)];
    end
    if ~exist(filename, 'file')
        filename = ['D' filename(2:end)];
    end
end    

if (filename & exist(filename, 'file'))
    disp(['Reading ', filename, '...']);
    cluster = dlmread(filename, '\t');
    %cluster(:,3) = signif(cluster(:,3), 1); % This is to ensure readability of old extracellular datafiles from Pittsburgh.
    cluster = ConvertTimeAndStim(filename, cluster);
    disp(['Read ', num2str(length(cluster)), ' records']);
else
    cluster = NaN;
    disp(['file not found: ' filename]);
end
