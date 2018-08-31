function [correctRespStruc] = correctResp_aniruddha();

%% Description:
% example script for how to extract stimulus types for pilot experiment on
% anticipatory blood flow signals with Aniruddha; 
% Clay Lacefield, 8/24/2011
% col8@columbia.edu

%% NOTE:
% doesn't yet include classification for catch trials
% also, doesn't really deal well with last events in file (because serial
% output from behavioral microcontroller may stop at some weird point, e.g.
% last event is a stimulus but does not include time of that event or
% result of that trial)


%% FIND FOLDER FOR THAT DAY
% go to the correct folder for the desired day
%%
[filename pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
filepath = [pathname filename];

% don't think I need these in this incarnation but let me check later
lev=0;
trig=0;
unrew=0;
rewStimNum=0;
rewNum=0;
noStimLevNum=0;
unrewLevNum=0;
levNum=0;

% initialize a few variables for array indices

numStim = 0;    % current # stimuli at this stage in loop through TXT file
corrInd = 0;        % current # correct responses, for indexing
incorrInd = 0;      % current # incorrect responses

numBotStim = 0;     % same for bottom/rewarded stimuli
corrRewInd = 0;
incorrRewInd = 0;

numTopStim = 0;     % same for top/unrewarded stimuli
corrUnrewInd = 0;
incorrUnrewInd = 0;

numCatStim = 0;     % same for catch trials
corrCatInd = 0;
incorrCatInd = 0;

% variables for response latency calculations
corrLatInd = 0;
incorrLatInd = 0;


% now read in the TXT file as a cell array
fullCell= textread(filepath,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% scan fullCell of text data to look for particular events
% NOTE: need to deal with end of file data better (can cut off stim list
% this way)
for txtInd = 3:2:(length(fullCell)-3)   % start reading after header (how long is it now?) and stop before end (or don't, I don't care but may cause problems)
    % First, look for correct responses
    event1 = fullCell{txtInd};
    if strfind(event1, 'bottom')
        stimType = 1;
        numStim = numStim + 1;
        numBotStim = numBotStim + 1;
        ev1time = fullCell{txtInd+1};
        stimTime = str2double(ev1time); % find the time of this stimulus
        event2 = fullCell{txtInd+2};
        ev2time = fullCell{txtInd+3};
        respTime = str2double(ev2time); % find the time of this stimulus
        if strfind(event2, 'REWARD')
            corrRespArr(numStim) = 1;
            corrRewInd = corrRewInd + 1;
            correctRewStimTime(corrRewInd) = stimTime; % stim time for correct lever presses
            corrInd = corrInd + 1;
            correctStimTime(corrInd) = stimTime;
            % latency of correct lever presses
            corrLatInd = corrLatInd + 1;
            corrLevPressLatency(corrLatInd) = respTime - stimTime;

            % else if incorrect witholding press, add to incorrect array
        else
            corrRespArr(numStim) = 0;
            incorrRewInd = incorrRewInd + 1;
            incorrectRewStimTime(incorrRewInd) = stimTime;
            incorrInd = incorrInd + 1;
            incorrectStimTime(incorrInd) = stimTime;
        end % end IF cond. looking for response to rewarded stimuli

        stimTypeArr(numStim) = stimType; % compile stim types for all stims
        stimTimeArr(numStim) = stimTime; % and times of the stims

    else
        if strfind(event1, 'top')
            stimType = 2; % stimType 2 = top/unrewarded trials
            numStim = numStim + 1;
            numTopStim = numTopStim + 1;

            ev1time = fullCell{txtInd+1};
            stimTime = str2double(ev1time); % find the time of this stimulus
            event2 = fullCell{txtInd+2};
            ev2time = fullCell{txtInd+3};
            respTime = str2double(ev2time); % find the time of this stimulus
            % stimTime = str2double(fullCell{txtInd+1}); % find the time of this stimulus
            if strfind(event2, 'unrewarded')
                corrRespArr(numStim) = 0;
                incorrUnrewInd = incorrUnrewInd + 1;
                incorrectUnrewStimTime(incorrUnrewInd) = stimTime; % stim time for incorrect lever presses
                incorrInd = incorrInd + 1;
                incorrectStimTime(incorrInd) = stimTime;
                % latency of incorrect lever presses
                incorrLatInd = incorrLatInd + 1;
                incorrLevPressLatency(incorrLatInd) = respTime - stimTime;
            else
                corrRespArr(numStim) = 1;
                corrUnrewInd = corrUnrewInd + 1;
                correctUnrewStimTime(corrUnrewInd) = stimTime;
                corrInd = corrInd + 1;
                correctStimTime(corrInd) = stimTime;
            end % end IF cond. looking for outcome of unrew stim trial

            stimTypeArr(numStim) = stimType; % compile stim types for all stims
            stimTimeArr(numStim) = stimTime; % and times of the stims

        end % end IF cond. looking for top/unrewarded stimuli

    end % end IF cond. looking for bottom vs. top stimuli

end  % end FOR loop looking through all events and times in data cell array

%% SAVE VARIABLES INTO A STRUC
% save important info into a data structure
try
    correctRespStruc.name = filepath;   % just record the name of the animal/file into the output structure
catch
end
try
    correctRespStruc.correctRewStimTime = correctRewStimTime;   % times (in ms) of all rewarded stimuli answered correctly
catch
end
try
    correctRespStruc.correctStimTime = correctStimTime; % times of all stimuli answered correctly
catch
end
try
    correctRespStruc.corrLevPressLatency = corrLevPressLatency; % latency of all correct, rewarded lever presses
catch
end
try
    correctRespStruc.incorrectRewStimTime = incorrectRewStimTime;   % times of all rewarded stimuli answered incorrectly
catch
end
try
    correctRespStruc.incorrectStimTime = incorrectStimTime;  % times of all stimuli answered incorrectly
catch
end
try
    correctRespStruc.incorrectUnrewStimTime = incorrectUnrewStimTime;   % times of all incorrect, unrewarded stimuli
catch
end
try
    correctRespStruc.incorrLevPressLatency = incorrLevPressLatency;     % latencies of incorrect lever presses to unrewarded stimuli
catch
end
try
    correctRespStruc.correctUnrewStimTime = correctUnrewStimTime;   % times of all unrewarded stimuli answered correctly
catch
end
try
    correctRespStruc.stimTypeArr = stimTypeArr;     % array of length = #stimuli where 2=top/unrewarded and 1= bottom/rewarded
catch
end
try
    correctRespStruc.stimTimeArr = stimTimeArr;     % array of length = #stimuli of times of each stimulus
catch
end
try
    correctRespStruc.corrRespArr = corrRespArr; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
end

%% Clear out all the variables except for the output structure
clear correctRewStimTime correctStimTime corrLevPressLatency incorrectRewStimTime incorrectStimTime incorrectUnrewStimTime incorrLevPressLatency correctUnrewStimTime stimTypeArr stimTimeArr corrRespArr;

%%




