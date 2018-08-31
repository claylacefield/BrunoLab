[filename pathname] = uigetfile('*.bin', 'Select a .bin file to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

i = 0;
ch1 = [];
ch2 = [];

while ~feof(fid)
    i = i+1;
    ch1(i+1) = fread(fid, 1,'*double');
    
    while ~feof(fid)
    ch2(i+1) = fread(fid, 1,'*double');
    end
    
    
end


fclose(fid);

plot(ch1); hold on; plot(ch2, 'r');