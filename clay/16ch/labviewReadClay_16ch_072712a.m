function [ch] = labviewReadClay_16ch(startSec)

% labviewRead
% 
% Script reads in multichannel binary files created in Labview on Phys
% computer in 2p room using script (currently) 
% 16chBehav_3devPCInUSBsave_053012e.vi
% That script saves 16channel data from the two PCI/RTSI NI boards (which 
% this script analyses) and 5 or so channels of behavioral data from the
% USB NI board.
% Data is saved as single-precision floating point (i.e. 32 bit) binary
% where each sample point from a channel is written after the other, then
% the next sample, etc. 
% This script reads chunks of binary data one sample point from each of the
% 16 channels (assumed) at a time and then does this over and over for a
% certain length of the original recording time.


%% START CODE

% choose file to analyze
[filename pathname] = uigetfile('*.bin', 'Select a .bin file to read');
filepath = [pathname filename];

numChan = 16;
sf = 30000;

% go to that directory
cd(pathname);

% figure out how many data points are in the dataset (for sizing output
% matrix)
fileinfo=dir(filename);     % find info on this data file
sizeBytes = fileinfo.bytes;     % record how many bytes it is
sizeData = sizeBytes/4/numChan;     % number of 32bit samples per channel

% open the file for reading
[fid, message] = fopen(filepath, 'r', 'b');

secToRead = 10;
startByte = startSec*sf*numChan*4;
sizeData = secToRead*sf;

fseek(fid, startByte, 'bof');       % skip some section of the file

i = 0;
ch = [zeros(numChan, sizeData)];


%% READ DATA
% read in a sample point from each of the 16channels at a time and do this
% for some length of time from the original recording (not reading in
% everything right now because the data set is so large).

% while ~feof(fid) 

for i = 1:sizeData
%i = i+1;
try
ch(:,i) = fread(fid, numChan,'*float32');  % reads 16 32bit numbers at a time
catch;
end

end

fclose(fid);    % close the original file after reading


%% PLOT

figure;
hold on; 
for j = 1:numChan
    plot(ch(j, :)+(2*j));
end




