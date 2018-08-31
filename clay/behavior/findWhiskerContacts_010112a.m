function [stimTrig, whiskContact, firstContactArr] = findWhiskerContacts()

% Clay 123111
% col8@columbia.edu


%% load in stimulus trigger signal DAT file
[filename pathname] = uigetfile('*.dat', 'Select a .dat file of stimulus triggers to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'b');

headerSize = SkipDATHeader(fid);

stim = fread(fid, '*float32');

%% now look for stimulus triggers 
%(which occur a few hundred ms before before the stepper moves)
% NOTE: that this will identify stimuli of both types (i.e. top and bot)

x = 0;
i = 1;
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

% sf = 32000;
% Nyquist = sf/2;
% whiskerSignal = BandFilt(whiskerSignal, 32000, 50, 10000);    % filter
% whiskerSignal = fir1(30, [50 10000]/Nyquist);    % what filter order?

%% and for each stimulus epoch, look for whisker contacts

whiskContact = [];
firstContactArr = [];

for j = 1:x
    whiskContactTrial = [];
    whiskTrial = whiskerSignal(stimEpochStart(j):stimEpochEnd(j));  % isolate whisker signal for this stimulus trial (either type)
    
    whiskContactTrial = LocalMinima(whiskTrial, 500, -0.3);  % detects peaks using LocalMinima (Buzsaki/Harris(kmf))
    whiskContactTrial = whiskContactTrial + stimEpochStart(j);  % adjust indices to make relative to whole recording (not just this trial)
    %NOTE: that this is slightly misaligned but shouldn't matter much
    
    % now concatenate the latest whisker contacts with the previous
    if length(whiskContactTrial)>0
        whiskContact = [whiskContact; whiskContactTrial];   % vertcat
        
        firstContact = whiskContactTrial(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr = [firstContactArr; firstContact];
    end
    
end

fclose('all');


%% now plot the whisker signal with putative whisker contacts

t=1:length(whiskerSignal); 

figure; 
plot(whiskerSignal); 
hold on; 
plot(t(whiskContact),whiskerSignal(whiskContact), 'r.');
plot(t(firstContactArr),whiskerSignal(firstContactArr), 'g.');

clear whiskerSignal;



