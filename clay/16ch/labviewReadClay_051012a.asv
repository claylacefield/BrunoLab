[filename pathname] = uigetfile('*.bin', 'Select a .bin file to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

i = 1;
ch = [];

while ~feof(fid) 
ch(:,i) = fread(fid, 2,'*double'); 
i = i+1;
end



fclose(fid);

plot(ch1); hold on; plot(ch2, 'r');