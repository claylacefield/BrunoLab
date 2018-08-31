function [correctRespStruc] = correctResp2p()


%% FIND FOLDER FOR THAT DAY
% go to the correct folder for the desired day
%%
[filename pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
filepath = [pathname filename];


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

% June 2013 new variables
rewArrInd = 0;  % NOTE: this is only for rewards with solenoid trig (i.e. not skipped)
numRew = 0;

% now read in the TXT file as a cell array
fullCell= textread(filepath,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% now find the index of the first actual data point
beginInd = (find(strcmp(fullCell, 'BEGIN DATA'))+1);

fullCell = fullCell(beginInd:end); % cutt off header then pad end
fullCell = [fullCell; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'];

% scan fullCell of text data to look for particular events
for txtInd = 1:2:length(fullCell)
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
        event3 = fullCell{txtInd+4}; % to see if cues are skipped
        ev3time = str2double(fullCell{txtInd+5});
        event4 = fullCell{txtInd+6}; 
        ev4time = str2double(fullCell{txtInd+7});
        
        
        
        if strfind(event2, 'REWARD')
            corrRespArr(numStim) = 1;
            corrRewInd = corrRewInd + 1;
            correctRewStimTime(corrRewInd) = stimTime; % stim time for correct lever presses
            corrInd = corrInd + 1;
            correctStimTime(corrInd) = stimTime;
            % latency of correct lever presses
            corrLatInd = corrLatInd + 1;
            corrLevPressLatency(corrLatInd) = respTime - stimTime;
            
            % see if reward is normal or otherwise
            if strfind(event3, 'reward tone skip')
               % tabulate skipped cue trials (may want to move this before previous section)
               
               % if solenoid is skipped, don't count in rewArr
               if strfind(event4, 'reward solenoid skip');
                  numRewToneSolSkip = numRewToneSolSkip + 1;
                  rewToneSolSkipInd(numRewToneSolSkip) = numStim;
                  rewToneSolSkipLatency(numRewToneSolSkip) = ev3time - stimTime;
               else
                   rewArrInd = rewArrInd + 1;
                   rewArr(rewArrInd) = 2;
               end
               
            elseif strfind(event3, 'reward solenoid skip');
                numRewSolSkip = numRewSolSkip + 1;
                rewSolSkipInd(numRewSolSkip) = numStim;
                rewSolSkipLatency(numRewSolSkip) = ev3time - stimTime;
                
            else
                rewArrInd = rewArrInd + 1;
                rewArr(rewArrInd) = 1; 
               
            end

           
        elseif strfind(event2, 'rew>pun switch')
            % to find these, need index of trial, and latency to response
            numRewPunSwitch = numRewPunSwitch + 1;
            rewPunSwitchInd(numRewPunSwitch) = numStim;
            rewPunSwitchLatency(numRewPunSwitch) = ev3time - stimTime;
            
            
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

    elseif (~isempty(strfind(event1, 'catch')))  || (~isempty(strfind(event1, 'top')))
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

        %end % end IF cond. looking for top/unrewarded stimuli

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
    correctRespStruc.correctRewStimTime = [];
end

try
    correctRespStruc.correctStimTime = correctStimTime;
catch
    correctRespStruc.correctStimTime = [];
end

try
    correctRespStruc.corrLevPressLatency = corrLevPressLatency;
catch
    correctRespStruc.corrLevPressLatency = [];
end

try
    correctRespStruc.incorrectRewStimTime = incorrectRewStimTime;
catch
    correctRespStruc.incorrectRewStimTime = [];
end

try
    correctRespStruc.incorrectStimTime = incorrectStimTime;
catch
    correctRespStruc.incorrectStimTime = [];
end

try
    correctRespStruc.incorrectUnrewStimTime = incorrectUnrewStimTime;
catch
    correctRespStruc.incorrectUnrewStimTime = [];
end

try
    correctRespStruc.incorrLevPressLatency = incorrLevPressLatency;
catch
    correctRespStruc.incorrLevPressLatency = [];
end

try
    correctRespStruc.correctUnrewStimTime = correctUnrewStimTime;
catch
    correctRespStruc.correctUnrewStimTime = [];
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

try
    correctRespStruc.corrRespArr = corrRespArr; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc.corrRespArr = [];
end

clear correctRewStimTime correctStimTime corrLevPressLatency incorrectRewStimTime incorrectStimTime incorrectUnrewStimTime incorrLevPressLatency correctUnrewStimTime stimTypeArr stimTimeArr corrRespArr;

%%




