% This is a single .dat file version of ProcessAll. See ProcessAll.m for more info.
%
% Randy Bruno, June 2000
%

% set current directory to desired experiment data directory before processing

n = input('# of channels for trode: ');
sign = input('sign (1 or -1): ');

[file, pathname] = uigetfile('*.dat');
%create a new directory of the same name as the file, but without '.dat'
cd(pathname);
newdir = file(1:(size(file,2)-4));
mkdir(newdir);
%create .lv and .tt files in the new directory
dat2tt(file, strcat(newdir, '\', newdir, '.lv'), strcat(newdir, '\', newdir, '.tt'), n, sign);

