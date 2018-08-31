function [x2] = binRead2pSingleName(filename)

% This function takes the place of Reardon's txt2binaries.m script and
% formats 16ch data acquired through the simple data acquisition program I
% wrote in LabView "16chBehav_3devPCInUSBsave_053012.vi", currently. This
% .vi outputs a binary file with one sample from each of the 16 written one
% after the other, in float32 (big endian, or whatever LabView defaults
% to). Output format is in .raw.(chNum) files for each channel, in float32
% LE format. Also outputs wideband .dat file for Neuroscope (Klusters
% suite)

%% SELECT FILE

% choose BIN file to analyze
%filename = dataFileArray{rowInd, 3};
%filepath = [pathname filename];

% currDir = dir;
% binInd = find(cellfun(@length, strfind({currDir.name}, '.bin')));  % get dir indices of .txt files
% binDatenum = [currDir(binInd).datenum]; % get datenums of .txt files
% [minDiff, minDiffInd] = min(abs(binDatenum - tifDatenum)); % find the .txt file acquired closest to the .tif file
% filename = currDir(binInd(minDiffInd)).name;

% adjust filename for weird dataFileArray formatting (apost. at end)
% filename = filename(1:(strfind(filename, '.bin')+3));

% just find a basename for this file, as Reardon's script would do
% nameEnd = strfind(filename, '.bin')-1;
% basename = filename(1:nameEnd);

nChannels = 8;
% nChannels = dataFileArray{rowInd, 7};
% sf = 1000;
scaleFactor = 1;

% go to that directory (should already be there in batch proc)
% cd(pathname);

%% FIGURE OUT FILE INFO AND OPEN DATA FILE

% figure out how many data points are in the dataset (for sizing output
% matrix)
fileinfo=dir(filename);     % find info on this data file
sizeBytes = fileinfo.bytes;     % record how many bytes it is
sizeData = sizeBytes/4/nChannels;     % number of 32bit samples per channel

[fid, message] = fopen(filename, 'r', 'b');

%% Read .bin data and write to output

x = fread(fid,'*float32');

x2 = reshape(x, nChannels, []);

fclose(fid);






