function bin2raw()

% This function takes the place of Reardon's txt2binaries.m script and
% formats 16ch data acquired through the simple data acquisition program I
% wrote in LabView "16chBehav_3devPCInUSBsave_053012.vi", currently. This
% .vi outputs a binary file with one sample from each of the 16 written one
% after the other, in float32 (big endian, or whatever LabView defaults
% to). Output format is in .raw.(chNum) files for each channel, in float32
% LE format. Also outputs wideband .dat file for Neuroscope (Klusters
% suite)


% choose file to analyze
[filename pathname] = uigetfile('*.bin', 'Select a .bin file to read');
filepath = [pathname filename];

% just find a basename for this file, as Reardon's script would do
nameEnd = strfind(filename, '.bin')-1;
basename = filename(1:nameEnd);

numChan = 16;
sf = 30000;

% go to that directory
cd(pathname);

% figure out how many data points are in the dataset (for sizing output
% matrix)
fileinfo=dir(filename);     % find info on this data file
sizeBytes = fileinfo.bytes;     % record how many bytes it is
sizeData = sizeBytes/4/numChan;     % number of 32bit samples per channel

[fid, message] = fopen(filepath, 'r', 'b');

%% Open output files
% open files for writing data into format for rest of Reardon's spike
% extraction suite (taken from txt2binaries.m, line 59)

fo=fopen([basename '.dat'],'w');

fRaw=zeros(nChannels,1);
for jj=1:nChannels 
    fRaw(jj) = fopen([basename '.raw.' int2str(jj-1)],'w');
end

%% Read .bin data and write to output 
% Reads in data from all channels one sample at a time
% and writes to output files (.raw.(chNum) and .dat)

i = 0;
ch = [zeros(numChan, sizeData)];

while ~feof(fid) 

i = i+1;
try
ch(:,i) = fread(fid, numChan,'*float32');  % reads 16 32bit numbers at a time (one sample for each channel)
catch;
end

end

fclose(fid);

% figure;
% hold on; 
% for j = 1:numChan
%     plot(ch(j, 1:30000)+(2*j));
% end




