function [shutTrig] = findShutterTrigs()

[filename pathname] = uigetfile('*.dat', 'Select a .dat file of shutter triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);

shutter = fread(fid, '*float32');

x=0;
shutTrig = [];

for i = 2:(length(shutter)-1)
    if (shutter(i)>4.88) && ((shutter(i)-shutter(i-1))>0.05) && (abs(shutter(i)-shutter(i+1))<0.05)
        x = x+1;
        shutTrig(x) = i; 
    end
end

%shutTrig = shutTrig(301:3300);  % kluge for only saving times of acquired frames


