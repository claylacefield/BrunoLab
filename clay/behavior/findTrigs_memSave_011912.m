

% Function to detect events in DAT files that doesn't read in entire binary
% data file (to save memory)
% Want to include: filter function, pos or neg, timeout


[filename pathname] = uigetfile('*.dat', 'Select a .dat file of stimulus triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);    % uses Randy function to skip his types of headers from ntrode



sizeA = 32000;   % number of samples to read at a time

while ~feof(fid)
    stim = fread(fid, sizeA,'*float32');      % read in only some chunk of data at a time
    
    i = 1;
    
    while i < (length(stim)-1)
        if (stim(i)>1)
            x = x+1;
            stimTrig(x) = i;    % save sample number of this event into array
            i = i + 32000;  % wait a second before looking for more stim triggers
        else
            i = i + 1;
        end
    end
    
    
end



