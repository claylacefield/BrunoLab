
% choose file to analyze
[filename pathname] = uigetfile('*.bin', 'Select a .bin file to read');
filepath = [pathname filename];

numChan = 8;
sf = 30000;

% go to that directory
cd(pathname);

% figure out how many data points are in the dataset (for sizing output
% matrix)
fileinfo=dir(filename);     % find info on this data file
sizeBytes = fileinfo.bytes;     % record how many bytes it is
sizeData = sizeBytes/4/numChan;     % number of 32bit samples per channel

[fid, message] = fopen(filepath, 'r', 'b');

i = 0;
ch = [zeros(numChan, sizeData)];

while ~feof(fid) 
i = i+1;
ch(:,i) = fread(fid, numChan,'*float32'); 

end

fclose(fid);

figure;
hold on; 
for j = 1:numChan
    plot(ch(j, 1:30000)+(2*j+16));
end




