function [correctRespStruc] = correctResp2p();


%% FIND FOLDER FOR THAT DAY
% go to the correct folder for the desired day
%%
[filename pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
filepath = [pathname filename];

% don't think I need these in this incarnation but let me check
lev=0;
trig=0;
unrew=0;
rewStimNum=0;
rewNum=0;
noStimLevNum=0;
unrewLevNum=0;
levNum=0;

% initialize a few variables for array indices
numStim = 0;
numBotStim = 0;
numTopStim = 0;
corrRewInd = 0;
corrInd = 0;
corrLatInd = 0;
incorrRewInd = 0;
incorrInd = 0;
incorrLatInd = 0;
incorrUnrewInd = 0;
corrUnrewInd = 0;

% now read in the TXT file as a cell array
fullCell= textread(filepath,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% scan fullCell of text data to look for particular events
% NOTE: need to deal with end of file data better (can cut off stim list
% this way)
for txtInd = 3:2:(length(fullCell)-3)
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
    correctRespStruc.name = filepath;
catch
end
try
    correctRespStruc.correctRewStimTime = correctRewStimTime;
catch
end
try
    correctRespStruc.correctStimTime = correctStimTime;
catch
end
try
    correctRespStruc.corrLevPressLatency = corrLevPressLatency;
catch
end
try
    correctRespStruc.incorrectRewStimTime = incorrectRewStimTime;
catch
end
try
    correctRespStruc.incorrectStimTime = incorrectStimTime;
catch
end
try
    correctRespStruc.incorrectUnrewStimTime = incorrectUnrewStimTime;
catch
end
try
    correctRespStruc.incorrLevPressLatency = incorrLevPressLatency;
catch
end
try
    correctRespStruc.correctUnrewStimTime = correctUnrewStimTime;
catch
end
try
    correctRespStruc.stimTypeArr = stimTypeArr;
catch
end
try
    correctRespStruc.stimTimeArr = stimTimeArr;
catch
end
try
    correctRespStruc.corrRespArr = corrRespArr; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
end

clear correctRewStimTime correctStimTime corrLevPressLatency incorrectRewStimTime incorrectStimTime incorrectUnrewStimTime incorrLevPressLatency correctUnrewStimTime stimTypeArr stimTimeArr corrRespArr;

%%




