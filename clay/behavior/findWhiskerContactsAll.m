function [fca2, fca3, filtWhiskSig, stimTrig, whiskContactCell, whiskContacts, firstContactArr, firstContactArrAbsT ] = findWhiskerContactsAll(x)

% Clay 011912
% col8@columbia.edu
%
% modified 102112 for use on Linux box

% sample frequency
%sf = 32000;

%% FIND STIMULUS TRIGGERS
% UI to choose and process a file of stimulus triggers
[stimTrig] = findStimTrigsAll();   % gives cell array of stim triggers for each fread epoch


%% now load in whisker signal DAT file ('.behav.3' for bottom sensor now, '.4' for top)
[filename pathname] = uigetfile('*.behav.3', 'Select a .dat file of whisker signals to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'l'); % 'le' for reardon-style data (;'be' for ntrode)

% headerSize = SkipDATHeader(fid);  % for ntrode data

%j = 0;
whiskContacts = [];

%sizeA = sf*100;   % number of samples to read at a time (100s worth)


whiskSig = fread(fid,'*float32');      % read in only some chunk of data at a time
% note that fread pads last file chunk with zeros up to sizeA

%i = 1;  % increments sample points within file read epoch
%j = 1;
%x = 0;  % increments stimulus trigger events

%whiskContactTemp = [];

% whiskSig = decimate(whiskSig,4);  % drop down to 8kHz
sf = 30000;  % used to decimate to 8k

% mean subtraction
whiskSig = whiskSig-mean(whiskSig);



%% filter (but filtering not necessary for new whisker sensor)
% lowFbound = 40;
% highFbound = 2000;
Nyquist = sf/2;
% filtWhiskSig = BandFilt(whiskSig, sf, lowFbound, highFbound);    % filter

MyFilt=fir1(100,[50 1000]/Nyquist);
filtWhiskSig = Filter0(MyFilt,whiskSig);

stdWhisk = std(filtWhiskSig);

clear whiskSig; % clear unfiltered to save memory

afterStim = 9500; % samples to wait after stim trig to avoid stim artifact

%% select out regions during stimulus epoch to look for whisker contacts
stimEpochStart = stimTrig + afterStim; % + sf/20;   % start looking for whisker contacts after motor artifact should have ended
stimEpochEnd = stimEpochStart + 1.7*sf;  % and stop just before the end motor artifact


%% and for each stimulus epoch, look for whisker contacts

whiskContactCell = {};
firstContactArr = [];

whiskContacts = [];
firstContactArrAbsT = [];

for k = 1:length(stimTrig)   % so for each stimulus trigger in the corresponding stimulus epoch
    
    whiskTrial = [];
    whiskContactTrial = [];
    
%     filtWhiskSig = whiskSig;
%     clear whiskSig;
    
%% select out epoch of whisker signal (based upon trial triggers)
    whiskTrial = filtWhiskSig(stimEpochStart(k):stimEpochEnd(k));  % isolate whisker signal for this stimulus trial (either type)
    % NOTE that this might fall outside of the whisker read epoch so
    % may generate error
    
    %whiskTrial = filtWhiskSig;
    
    %% detect peaks (whisker touches)
    timeoutMs = 10;  % how many ms minimum between whisk touches
    timeoutSamp = timeoutMs*sf/1000;    % figures out how many samples in timeout
    stdThresh = 0.4;  % stdev threshold for whisker touch detection
    
    whiskContactTrial = LocalMinima(-whiskTrial, timeoutSamp, -(stdThresh*stdWhisk));  % detects peaks using LocalMinima (Buzsaki/Harris(kmf))
    %whiskContactTrial = whiskContactTrial + stimEpochStart(k);  % adjust indices to make relative to whole recording (not just this trial)
    %NOTE: that this is slightly misaligned but shouldn't matter much
    %NOTE: now not adjusting to absolute time because trying to make
    %single-trial cells for using with linescan frames from VSD imaging
    
    
    %% now concatenate the latest whisker contacts with the previous
    if length(whiskContactTrial)>0
        whiskContactTrial = whiskContactTrial + afterStim;  % now adjusted for time since start of this trial
        whiskContactCell{k} = whiskContactTrial;   % and put in cell array (since can be diff num of touches in each trial)
        whiskContactTrialAdj = whiskContactTrial+stimTrig(k);   % this gives absolute time of touches (vs. whole session) in this trial
        whiskContacts = vertcat(whiskContacts, whiskContactTrialAdj); % and concatenate with all other trials
        
        firstContact = whiskContactTrial(1);  % just isolates the first whisker contact in the stimulus trial
        firstContactArr(k) = firstContact;  % array of first contact times (relative to trial)
        firstContactArrAbsT(k) = firstContact + stimTrig(k);  % array of first contact times (absolute, vs. session)
    else
        whiskContactCell{k} = 0;  % don't know if I need this
        firstContactArr(k) = 0;
        firstContactArrAbsT(k) = 0;
        
    end
    
end

%j = j + 1;


%clear filtWhiskSig;     % clear filtered to save memory

fclose('all');


%% now plot the whisker signal with putative whisker contacts

% t=1:length(whiskSignal);
%
% figure;
% plot(whiskerSignal);
% hold on;
% plot(filtWhiskSig, 'g');
% plot(t(whiskContact),whiskerSignal(whiskContact), 'r.');
% plot(t(firstContactArr),whiskerSignal(firstContactArr), 'c.');

fca2 = (firstContactArrAbsT ~= 0);
fca3 = firstContactArrAbsT(fca2); % this weeds out trials with no whisker hits
% % 
% % 

% plots first whisker-contact triggered LFP
figure; hold on;
for k = 1:length(fca3)
    plot(10*(x(fca3(k):(fca3(k)+2*sf)))+k);
end
    
    

