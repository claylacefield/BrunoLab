function [stimTrig] = findStimTrigs()

[filename pathname] = uigetfile('*.dat', 'Select a .dat file of stimulus triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);

stim = fread(fid, '*float32');

x=0;
stimTrig = [];

while i < (length(stim)-1)
    if (stim(i)>1)
        x = x+1;
        stimTrig(x) = i;    % save sample number of this event into array
        i = i + 32000;
    else
        i = i + 1;
    end
    
end

clear stim;

stimEpoch = stimTrig + 12200;

[filename pathname] = uigetfile('*.dat', 'Select a .dat file of whisker signals to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);

whiskerSignal = fread(fid, '*float32');
