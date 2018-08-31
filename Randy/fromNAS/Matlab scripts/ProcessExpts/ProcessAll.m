% This script performs pre-processing of experiment data acquired using the
% Labview tetrode VI's. Directories are created for each .dat file. The files
% are moved to their corresponding directories and corresponding .lv and .tt
% files are generated using the dat2tt function. The tt files can be read into
% MClust for spike sporting.
%
% Randy Bruno, June 2000
%
% set current directory to desired experiment data directory before running

ctx = input('# of channels for cortical trode: ');
thl = input('# of channels for thalamic trode: ');
sign = input('sign (1 or -1): ');

% get list of .dat files in current directory
files = dir('*.dat');

% loop through list of .dat files
for f = 1:size(files)
   file = files(f).name
   %create a new directory of the same name as the file, but without '.dat'
   newdir = file(1:(size(file,2)-4));
   mkdir(newdir);
   
   %determine file type
   pos = cat(2, findstr(newdir, 'ctx'), findstr(newdir, 'thl'));
   type = newdir(pos:pos+2);

   %create .lv and .tt files in the new directory
   dat2tt(file, strcat(newdir, '\', newdir, '.lv'), strcat(newdir, '\', newdir, '.tt'), eval(type), sign);
end
