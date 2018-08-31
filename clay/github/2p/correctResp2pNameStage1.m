function [correctRespStruc] = correctResp2pNameStage1(sessionBasename, rewTime)

%% Clay 2017
% Making new script for stage1 that also looks for solenoid skips, etc.
% want:
% all rewards: rew
% normal mouse rewards: rew1
% sol skip: rew5
% but remember later sessions might have text for sync stim movement

%% Read TXT file
% [filename pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
% filepath = [pathname filename];

% 102814 now getting .txt filename from sessionBasename (from .bin)
filename = [sessionBasename '.txt'];


% need to correct for animals with initial reward on lick program
txtDir = dir;
for fileNum = 1: length(txtDir)
    if strfind(txtDir(fileNum).name, filename)
        txtDatenum = txtDir(fileNum).datenum;
    end
end
initRew = 0;
if txtDatenum < 735750
    initRew = 1;
end

% initialize a few variables for array indices
numStim = 0;
numBotStim = 0;
%rewInd = 0;
rewArrInd = 0;  % NOTE: this is only for rewards with solenoid trig (i.e. not skipped)
%numRew = 0;

rewTime5 = [];
rewTime6 = [];
numRew5 = 0;
numRew6 = 0;

initDelay = 0;

% now read in the TXT file as a cell array
fullCell= textread(filename,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% now find the index of the first actual data point
beginInd = (find(strcmp(fullCell, 'BEGIN DATA'))+1);

if isempty(beginInd)
    beginInd = 1;
end

fullCell = fullCell(beginInd:end); % cut off header then pad end
fullCell = [fullCell; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'];

% scan fullCell of text data to look for particular events
for txtInd = 1:length(fullCell)-1
    % First, look for normal rewards
    event1 = fullCell{txtInd};
    ev1time = str2double(fullCell{txtInd+1});
    
    if strfind(event1, 'REWARD')
        stimType = 1;
        numStim = numStim + 1;
        numBotStim = numBotStim + 1;
        
        if strfind(event1, 'mouse')
            rewType = 1;
        elseif strfind(event1, 'random')
            rewType = 2;
        elseif strfind(event1, 'experimenter')
            rewType = 3;
        end
        
        [rewArrVal] = corrRespStage1RewTypeSub(fullCell, txtInd, rewType);
        
        if rewArrVal ~= 5 && rewArrVal ~=6
            rewArrInd = rewArrInd + 1;
            rewArr(rewArrInd) = rewArrVal;
            ardRewT(rewArrInd) = ev1time;
        elseif rewArrVal == 5
            numRew5 = numRew5 +1;
            lastRewInd5(numRew5) = rewArrInd; % ind of last normal reward (labview time)
            rewTime5ard(numRew5) = (ev1time-ardRewT(rewArrInd));  % find absolute time of rew5 based upon time since last rew (best possible)
        elseif rewArrVal == 6
            numRew6 = numRew6 +1;
            lastRewInd6(numRew6) = rewArrInd; % ind of last normal reward (labview time)
            rewTime6ard(numRew6) = (ev1time-ardRewT(rewArrInd));
        end
    end % end IF cond. looking for bottom vs. top stimuli
end  % end FOR loop looking through all events and times in data cell array


%% fix for times in which a reward might be missed in labview
% which can happen in old stage1

if length(rewTime) ~= length(rewArr)
    rewCountDiff = find(max(xcorr(diff(rewTime), diff(ardRewT))));
    % chop off rews from longer one
    if rewCountDiff > 0
        rewArr = rewArr(rewCountDiff+1:end);
        ardRewT = ardRewT(rewCountDiff+1:end);
    elseif rewCoundDiff < 0
        rewArr = rewArr(1:end+rewCountDiff);
        ardRewT = ardRewT(1:end+rewCountDiff);
    end
    
    if numRew5 ~=0
        lastRewInd5 = lastRewInd5 - rewCountDiff;
        bad5inds = find(lastRewInd5 == 0);
        lastRewInd5(bad5inds) = [];
        rewTime5ard(bad5inds) = [];
    end
    
    if numRew6 ~=0
        lastRewInd6 = lastRewInd6 - rewCountDiff;
        bad6inds = find(lastRewInd6 == 0);
        lastRewInd6(bad6inds) = [];
        rewTime6ard(bad6inds) = [];
    end
    
end

if numRew5~=0
    for i = 1:length(lastRewInd5)
        lastRewTime = rewTime(lastRewInd5(i)); % time of last normal reward (labview time)
        rewTime5 = [rewTime5 (lastRewTime + rewTime5ard(i))];
    end
end

if numRew6~=0
    for i = 1:length(lastRewInd6)
        lastRewTime = rewTime(lastRewInd6(i)); % time of last normal reward (labview time)
        rewTime6 = [rewTime6 (lastRewTime + rewTime6ard(i))];
    end
end

%% SAVE VARIABLES INTO A STRUC
% save important info into a data structure



try
    correctRespStruc.name = filename;
catch
end

try
    correctRespStruc.initDelay = initDelay;
catch
end

try
    correctRespStruc.stimTypeArr = stimTypeArr;
catch
    correctRespStruc.stimTypeArr = [];
end
try
    correctRespStruc.stimTimeArr = stimTimeArr;
catch
    correctRespStruc.stimTimeArr = [];
end


% new output variables (for skip sessions mostly)
try
    correctRespStruc.rewArr = rewArr; % for each reward, tells what kind (for skips, switches)
catch
    correctRespStruc.rewArr = [];
end


% new outputs
try
    correctRespStruc.rewTime5 = rewTime5;
catch
    correctRespStruc.rewTime5 = [];
end

try
    correctRespStruc.rewTime6 = rewTime6;
catch
    correctRespStruc.rewTime6 = [];
end

try
    correctRespStruc.ardRewT = ardRewT;
catch
    correctRespStruc.ardRewT = [];
end
