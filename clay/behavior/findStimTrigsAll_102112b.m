function [stimTrig] = findStimTrigsAll();

% Function to detect events in DAT files that doesn't read in entire binary
% data file (to save memory)
% Want to include: filter function, pos or neg, timeout
% NOTE that this script now downsamples the DAT file (just takes one out of
% every 4 samples) so must use with similarly downsampled DAT files
%
% INPUT: use UI to select DAT file of stimulus triggers
% OUTPUT: gives array of indices of identified stimulus triggers, for
% whatever timebase the data file is (now downsampled to 8kHz).
% 
% NOTE 022012: as of this time, just using downsampled signal instead of
% dividing data up into chunks; I think changing the filtering method for
% the whisker signal data in "findWhiskerContactsAll.m" will alleviate need
% even for downsampling however;
% NOTE also that the "All" in the title refers to prior versions where I
% was using the chunk analysis method
%
% 102112: rewrote this script to use on Linux box, i.e. all data processed
% at once (for computers with lots of memory)


[filename pathname] = uigetfile('*.behav.0', 'Select a file of stimulus triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'l');


stimTrig = [];

sf = 30000;

%sizeA = 3200000;   % number of samples to read at a time

% while ~feof(fid)
    stim = fread(fid,'*float32');      % read in data
    
%     stim = decimate(stim,4);  % downsample to 8kHz
    
    i = 1;  % increments sample points within file read epoch
    x = 0;  % increments stimulus trigger events
    
    %stimTrigTemp = [];
    
    while i < (length(stim)-1)  % go through this chunk to look for stimulus trigger events
        if (stim(i)>1)      % threshold is 1V (noise is very low and TTL at onset is 5V)
            x = x+1;
            stimTrig(x) = i;    % save sample number/index of this event into array
            i = i + sf;  % wait a second before looking for more stim triggers
        else
            i = i + 1;  % if no thresh cross then go to next sample
        end
    end
    

    
% end

clear stim;

fclose(fid);

