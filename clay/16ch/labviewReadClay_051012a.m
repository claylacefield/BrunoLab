[filename pathname] = uigetfile('*.bin', 'Select a .bin file to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

i = 0;
ch1 = [];
ch2 = [];


ch1 = fread(fid, 1,'*double'); 




fclose(fid);

plot(ch1); hold on; plot(ch2, 'r');