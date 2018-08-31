function [stimTrig] = findWhiskerContacts()


%% load in stimulus trigger signal DAT file
[filename pathname] = uigetfile('*.dat', 'Select a .dat file of stimulus triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);

stim = fread(fid, '*float32');

%% now look for stimulus triggers 
%(which occur a few hundred ms before before the stepper moves)
% NOTE: that this will identify stimuli of both types (i.e. top and bot)

x=0;
stimTrig = [];

while i < (length(stim)-1)
    if (stim(i)>1)
        x = x+1;
        stimTrig(x) = i;    % save sample number of this event into array
        i = i + 32000;  % wait a second before looking for more stim triggers
    else
        i = i + 1;
    end
end

clear stim;     % clear stimulus trigger signal to save memory

stimEpochStart = stimTrig + 12200;   % start looking for whisker contacts after motor artifact should have ended
stimEpochEnd = stimEpochStart + 38000;  % and stop just before the end motor artifact


%% now load in whisker signal DAT file
[filename pathname] = uigetfile('*.dat', 'Select a .dat file of whisker signals to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);

whiskerSignal = fread(fid, '*float32');

%% and for each stimulus epoch, look for whisker contacts
for j = 1:(length(x)-1)
    whiskTrial = whiskerSignal(stimEpochStart(x):stimEpochEnd(x));
    
    for k = 1:length(whiskTrial)
        if whiskTrial < 1
            whiskContact(n) = stimEpochStart(x) + k;
            n = n +1:
        end
    end
end






