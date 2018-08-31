function h5toMatClay(ch, endFr)

% This function reads in a selected exported motion-corrected .h5 


%% clear workspace
clear all;

%% select data and map it to the RAM

[filename, path] = uigetfile('*.h5', 'Select .h5 file to read');

nam = [path, filename];  % full name of the data file

[~, basename, file_type] = fileparts(nam);

% convert the data to mat file

%nam_mat = [path, filename, '.mat'];

disp('converting H5 to MAT'); tic;
segChan = ch; %2;  % channel to segment
%endFr = 2000;   % frame to truncate data at (for testing)
info = h5info(nam);

if endFr == 0
    T = info.Datasets.Dataspace.Size(5);   % number of frames
else
    T = endFr;
end

d1 = info.Datasets.Dataspace.Size(2);   % height of the image
d2 = info.Datasets.Dataspace.Size(3);   % width of the image
Ysiz = [d1, d2, T]';

disp(['Reading ' num2str(T) ' frames from ch' num2str(ch)]);
Y = h5read(nam, '/imaging', [segChan 1 1 1 1], [1 d1 d2 1 T], [2 1 1 1 1]);
Y = squeeze(Y);

save([basename '_ch' num2str(ch) '.mat'], 'Y', 'Ysiz', '-v7.3');
clear Y Ysiz;
toc;



