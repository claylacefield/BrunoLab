function [stimTrig] = findStimTrigs();

% Function to detect events in DAT files that doesn't read in entire binary
% data file (to save memory)
% Want to include: filter function, pos or neg, timeout


[filename pathname] = uigetfile('*.dat', 'Select a .dat file of stimulus triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);    % uses Randy function to skip his types of headers from ntrode

j = 0;
stimTrig = [];

sizeA = 3200000;   % number of samples to read at a time

while ~feof(fid)
    stim = fread(fid, sizeA,'*float32');      % read in only some chunk of data at a time
    % note that fread pads last file chunk with zeros up to sizeA
    
    i = 1;  % increments sample points within file read epoch
    x = 0;  % increments stimulus trigger events
    
    stimTrigTemp = {};
    
    while i < (length(stim)-1)  % go through this chunk to look for stimulus trigger events
        if (stim(i)>1)      % threshold is 1V (noise is very low and TTL at onset is 5V)
            x = x+1;
            stimTrigTemp(x) = i;    % save sample number/index of this event into array
            i = i + 32000;  % wait a second before looking for more stim triggers
        else
            i = i + 1;  % if no thresh cross then go to next sample
        end
    end
    
    % NOTE that this method may create spurious triggers, if a stimulus
    % trigger event (~100ms) is split between file chunks (can fix this
    % later)
    
   %stimTrigTemp = stimTrigTemp+(j*sizeA);
    stimTrig{j} = stimTrigTemp;
    
    j = j + 1;  % increment number of file chunk just analyzed
    
    clear stim stimTrigTemp;

    
end

fclose(fid);

