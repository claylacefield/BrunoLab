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

numRewToneSolSkip = 0;
numRewToneSkip = 0;
numRewSolSkip = 0;
numRewPunSwitch = 0; 
numPunRewSwitch = 0;

% now read in the TXT file as a cell array
fullCell= textread(filepath,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% now find the index of the first actual data point
beginInd = (find(strcmp(fullCell, 'BEGIN DATA'))+1);

fullCell = fullCell(beginInd:end); % cut off header then pad end
fullCell = [fullCell; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'; 'pad'; '0'];

% scan fullCell of text data to look for particular events
for txtInd = 1:2:length(fullCell)
    % First, look for correct responses
    event1 = fullCell{txtInd};
    if strfind(event1, 'bottom')
        stimType = 1;
        numStim = numStim + 1;
        numBotStim = numBotStim + 1;
        ev1time = str2double(fullCell{txtInd+1});
        event2 = fullCell{txtInd+2};
        ev2time = str2double(fullCell{txtInd+3});
        event3 = fullCell{txtInd+4}; % to see if cues are skipped
        ev3time = str2double(fullCell{txtInd+5});
        event4 = fullCell{txtInd+6};
        ev4time = str2double(fullCell{txtInd+7});
        
        
        % now see what outcome of trial is
        if strfind(event2, 'REWARD')
            corrRespArr(numStim) = 1;
            corrRewInd = corrRewInd + 1;
            correctRewStimTime(corrRewInd) = ev1time; % stim time for correct lever presses
            corrInd = corrInd + 1;
            correctStimTime(corrInd) = ev1time;
            % latency of correct lever presses
            corrLatInd = corrLatInd + 1;
            corrLevPressLatency(corrLatInd) = ev2time - ev1time;
            
            % see if reward is normal or otherwise
            if strfind(event3, 'reward tone skip')
                % tabulate skipped cue trials (may want to move this before previous section)
                
                
                % if solenoid is skipped, don't count in rewArr
                if strfind(event4, 'reward solenoid skip');
                    numRewToneSolSkip = numRewToneSolSkip + 1;
                    rewToneSolSkipInd(numRewToneSolSkip) = numStim;
                    rewToneSolSkipLatency(numRewToneSolSkip) = ev4time - ev1time;
                else    % otherwise do count in reward list
                    rewArrInd = rewArrInd + 1;
                    rewArr(rewArrInd) = 2;  % "2" is reward tone skip in rewArr
                    
                    numRewToneSkip = numRewToneSkip + 1;
                    rewToneSkipInd(numRewToneSkip) = numStim;
                    rewToneSkipLatency(numRewToneSkip) = ev3time - ev1time;
                    
                end
                
            elseif strfind(event3, 'reward solenoid skip');
                numRewSolSkip = numRewSolSkip + 1;
                rewSolSkipInd(numRewSolSkip) = numStim;
                rewSolSkipLatency(numRewSolSkip) = ev3time - ev1time;
                
            else
                rewArrInd = rewArrInd + 1;
                rewArr(rewArrInd) = 1;  % "1" is normal reward in rewArr
                
            end
            
            
        elseif strfind(event2, 'rew>pun switch')
            
            corrRespArr(numStim) = 1; % technically the response is correct
            
            % to find these, need index of trial, and latency to response
            numRewPunSwitch = numRewPunSwitch + 1;
            rewPunSwitchInd(numRewPunSwitch) = numStim;
            rewPunSwitchLatency(numRewPunSwitch) = ev2time - ev1time;
            
            
            % else if incorrect witholding press, add to incorrect array
        else
            corrRespArr(numStim) = 0;
            incorrRewInd = incorrRewInd + 1;
            incorrectRewStimTime(incorrRewInd) = ev1time;
            incorrInd = incorrInd + 1;
            incorrectStimTime(incorrInd) = ev1time;
        end % end IF cond. looking for response to rewarded stimuli
        
        stimTypeArr(numStim) = stimType; % compile stim types for all stims
        stimTimeArr(numStim) = ev1time; % and times of the stims
        
    elseif (~isempty(strfind(event1, 'catch')))  || (~isempty(strfind(event1, 'top')))
        stimType = 2; % stimType 2 = top/unrewarded trials
        numStim = numStim + 1;
        numTopStim = numTopStim + 1;
        
        ev1time = fullCell{txtInd+1};
        ev1time = str2double(ev1time); % find the time of this stimulus
        event2 = fullCell{txtInd+2};
        ev2time = str2double(fullCell{txtInd+3}); % find the time of this stimulus
        event3 = fullCell{txtInd+4}; % to see if cues are skipped
        ev3time = str2double(fullCell{txtInd+5});
        event4 = fullCell{txtInd+6};
        ev4time = str2double(fullCell{txtInd+7});
        
        
        if strfind(event2, 'unrewarded')
            corrRespArr(numStim) = 0;
            incorrUnrewInd = incorrUnrewInd + 1;
            incorrectUnrewStimTime(incorrUnrewInd) = ev1time; % stim time for incorrect lever presses
            incorrInd = incorrInd + 1;
            incorrectStimTime(incorrInd) = ev1time;
            % latency of incorrect lever presses
            incorrLatInd = incorrLatInd + 1;
            incorrLevPressLatency(incorrLatInd) = ev2time - ev1time;
        elseif strfind(event2, 'pun>rew switch')
            corrRespArr(numStim) = 0; % technically the response is correct
            
            % to find these, need index of trial, and latency to response
            numPunRewSwitch = numPunRewSwitch + 1;
            punRewSwitchInd(numPunRewSwitch) = numStim;
            punRewSwitchLatency(numPunRewSwitch) = ev2time - ev1time;
            
            rewArrInd = rewArrInd + 1;
            rewArr(rewArrInd) = 3;  % "3" is pun>rew switch reward in rewArr
            
        else
            corrRespArr(numStim) = 1;
            corrUnrewInd = corrUnrewInd + 1;
            correctUnrewStimTime(corrUnrewInd) = ev1time;
            corrInd = corrInd + 1;
            correctStimTime(corrInd) = ev1time;
        end % end IF cond. looking for outcome of unrew stim trial
        
        stimTypeArr(numStim) = stimType; % compile stim types for all stims
        stimTimeArr(numStim) = ev1time; % and times of the stims
        
        %end % end IF cond. looking for top/unrewarded stimuli
        
    elseif strfind(event1, 'random reward!!!')
        
        if strfind(event2, 'random reward solenoid skip')
            % hmmm... don't have any way of establishing this time
            % numRandRewSolSkip = 
        else
        rewArrInd = rewArrInd + 1;
        rewArr(rewArrInd) = 4;  % "4" is random reward in rewArr
        end
        
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




