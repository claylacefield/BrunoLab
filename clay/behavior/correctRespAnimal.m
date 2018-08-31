function [correctRespStruc, animalCorrResp] = correctRespAnimal()

%% [correctRespStruc, animalCorrResp] = correctRespAnimal();


%% FIND FOLDER FOR THAT DAY
% go to the correct folder for the desired day
cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);

currDir = dir;

numRec = 0;

%% LOOK THROUGH ALL FILES IN THE FOLDER FOR THIS DAY
for i = 3:length(currDir);
    
    
    
    %%  LOOK FOR TEXT FILES OF DATA AND PARSE FOR EVENTS AND EVENT TIMES
    if strfind(currDir(i).name, '.txt');    % make sure file is .txt, thus data
        numRec = numRec + 1;
        file = currDir(i).name;
        
        %% FIND FOLDER FOR THAT DAY
        % go to the correct folder for the desired day
        %%
%         [filename, pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
%         filepath = [pathname filename];
        
        % filename = dataFileArray{rowInd, 4};
        
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
        
        rewInd = 0;
        % rewStimInd = 0;
        punInd = 0;
        
        punToneSkipInd = 0;
        
        
        % June 2013 new variables
        rewArrInd = 0;  % NOTE: this is only for rewards with solenoid trig (i.e. not skipped)
        %numRew = 0;
        
        punArrInd = 0;
        %numPun = 0;
        
        numRewToneSolSkip = 0;
        numRewToneSkip = 0;
        numRewSolSkip = 0;
        numRewPunSwitch = 0;
        numPunRewSwitch = 0;
        numRandRewSolSkip = 0;
        
        % now read in the TXT file as a cell array
        fullCell= textread(file,'%s', 'delimiter', '\n');   % read in whole file as cell array
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
                    %             corrRewInd = corrRewInd + 1;
                    %             correctRewStimInd(corrRewInd) = numStim; % stim time for correct lever presses
                    corrInd = corrInd + 1;
                    correctStimInd(corrInd) = numStim;
                    % latency of correct lever presses
                    corrLatInd = corrLatInd + 1;
                    corrLevPressLatency(corrLatInd) = ev2time - ev1time;
                    
                    % see if reward is normal or otherwise
                    if strfind(event3, 'reward tone skip')
                        % tabulate skipped cue trials (may want to move this before previous section)
                        
                        
                        % if solenoid is skipped, don't count in rewArr
                        if strfind(event4, 'reward solenoid skip');
                            numRewToneSolSkip = numRewToneSolSkip + 1;
                            rewToneSolSkipStimInd(numRewToneSolSkip) = numStim;
                            rewToneSolSkipLatency(numRewToneSolSkip) = ev4time - ev1time;
                        else    % otherwise do count in reward list
                            rewArrInd = rewArrInd + 1;
                            rewArr(rewArrInd) = 2;  % "2" is reward tone skip in rewArr
                            
                            numRewToneSkip = numRewToneSkip + 1;
                            rewToneSkipInd(numRewToneSkip) = rewArrInd;
                            rewToneSkipStimInd(numRewToneSkip) = numStim;
                            rewToneSkipLatency(numRewToneSkip) = ev3time - ev1time;
                            
                        end
                        
                    elseif strfind(event3, 'reward solenoid skip');
                        numRewSolSkip = numRewSolSkip + 1;
                        rewSolSkipStimInd(numRewSolSkip) = numStim;
                        rewSolSkipLatency(numRewSolSkip) = ev3time - ev1time;
                        
                    else % for normal reward
                        corrRewInd = corrRewInd + 1;
                        correctRewStimInd(corrRewInd) = numStim; % stim time for correct lever presses
                        
                        rewInd = rewInd + 1;
                        rewStimInd(rewInd) = numStim; % 072713: stim indices of normal rewards
                        rewArrInd = rewArrInd + 1;
                        rewArr(rewArrInd) = 1;  % "1" is normal reward in rewArr
                        
                    end
                    
                    
                elseif strfind(event2, 'switch')
                    
                    corrRespArr(numStim) = 1; % technically the response is correct
                    
                    corrInd = corrInd + 1;
                    correctStimInd(corrInd) = numStim;
                    
                    % to find these, need index of trial, and latency to response
                    numRewPunSwitch = numRewPunSwitch + 1;
                    rewPunSwitchStimInd(numRewPunSwitch) = numStim;
                    rewPunSwitchLatency(numRewPunSwitch) = ev2time - ev1time;
                    
                    punArrInd = punArrInd + 1;
                    punArr(punArrInd) = 2; % "2" is rew>pun switch in punArr
                    
                    % else if incorrect witholding press, add to incorrect array
                else    % incorrect lack of lever lift for rew trial
                    corrRespArr(numStim) = 0;
                    incorrRewInd = incorrRewInd + 1;
                    incorrectRewStimInd(incorrRewInd) = numStim;
                    incorrInd = incorrInd + 1;
                    incorrectStimInd(incorrInd) = numStim;
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
                    
                    incorrInd = incorrInd + 1;
                    incorrectStimInd(incorrInd) = numStim;
                    % latency of incorrect lever presses
                    incorrLatInd = incorrLatInd + 1;
                    incorrLevPressLatency(incorrLatInd) = ev2time - ev1time;
                    
                    punArrInd = punArrInd + 1;
                    if strfind(event3, 'skip')  % for punishment tone skip
                        punArr(punArrInd) = 2;
                        punToneSkipInd = punToneSkipInd +1;
                        punToneSkipStimInd(punToneSkipInd) = numStim;
                    else    % or normal punishment
                        punArr(punArrInd) = 1;  % "1" is normal punishment in punArr
                        
                        incorrUnrewInd = incorrUnrewInd + 1;
                        incorrectUnrewStimInd(incorrUnrewInd) = numStim; % stim time for incorrect lever presses
                        
                        punInd = punInd +1;
                        punStimInd(punInd) = numStim;
                        
                    end
                    
                    
                elseif strfind(event2, 'pun>rew switch')
                    corrRespArr(numStim) = 0; % technically the response is incorrect
                    
                    % NOTE: switches are not counted in normal correct/incorrect
                    % stim indices
                    
                    incorrInd = incorrInd + 1;
                    incorrectStimInd(incorrInd) = numStim;
                    
                    % to find these, need index of trial, and latency to response
                    numPunRewSwitch = numPunRewSwitch + 1;
                    punRewSwitchStimInd(numPunRewSwitch) = numStim;
                    punRewSwitchLatency(numPunRewSwitch) = ev2time - ev1time;
                    
                    if ~strfind(event4, 'reward solenoid skip')
                        rewArrInd = rewArrInd + 1;
                        rewArr(rewArrInd) = 3;  % "3" is pun>rew switch reward in rewArr
                    end
                    
                else    % correct witholding of lever lift for unrew
                    corrRespArr(numStim) = 1;
                    corrUnrewInd = corrUnrewInd + 1;
                    correctUnrewStimInd(corrUnrewInd) = numStim;
                    corrInd = corrInd + 1;
                    correctStimInd(corrInd) = numStim;
                    
                end % end IF cond. looking for outcome of unrew stim trial
                
                stimTypeArr(numStim) = stimType; % compile stim types for all stims
                stimTimeArr(numStim) = ev1time; % and times of the stims
                
                %end % end IF cond. looking for top/unrewarded stimuli
                
            elseif strfind(event1, 'random reward!!!')
                
                event2 = fullCell{txtInd+2};
                
                if strfind(event2, 'random reward solenoid skip')
                    % hmmm... don't have any way of establishing this time
                    %              numRandRewSolSkip = numRandRewSolSkip + 1;
                else
                    rewArrInd = rewArrInd + 1;
                    rewArr(rewArrInd) = 4;  % "4" is random reward in rewArr
                end
                
            end % end IF cond. looking for bottom vs. top stimuli
            
        end  % end FOR loop looking through all events and times in data cell array
        
        
        %% SAVE VARIABLES INTO A STRUC
% save important info into a data structure
try
    correctRespStruc(numRec).name = filename;
catch
end

try
    correctRespStruc(numRec).correctRewStimInd = correctRewStimInd; % NOTE: no skip/switches
catch
    correctRespStruc(numRec).correctRewStimInd = [];
end

try
    correctRespStruc(numRec).correctStimInd = correctStimInd; % NOTE: this includes skip/switches
catch
    correctRespStruc(numRec).correctStimInd = [];
end

try
    correctRespStruc(numRec).corrLevPressLatency = corrLevPressLatency; % NOTE: this includes skip/switches
catch
    correctRespStruc(numRec).corrLevPressLatency = [];
end

try
    correctRespStruc(numRec).incorrectRewStimInd = incorrectRewStimInd; % NOTE: no skip/switches
catch
    correctRespStruc(numRec).incorrectRewStimInd = [];
end

try
    correctRespStruc(numRec).incorrectStimInd = incorrectStimInd; % NOTE: this includes skip/switches
catch
    correctRespStruc(numRec).incorrectStimInd = [];
end

try
    correctRespStruc(numRec).incorrectUnrewStimInd = incorrectUnrewStimInd; % NOTE: no skip/switches
catch
    correctRespStruc(numRec).incorrectUnrewStimInd = [];
end

try
    correctRespStruc(numRec).incorrLevPressLatency = incorrLevPressLatency;
catch
    correctRespStruc(numRec).incorrLevPressLatency = [];
end

try
    correctRespStruc(numRec).correctUnrewStimInd = correctUnrewStimInd;
catch
    correctRespStruc(numRec).correctUnrewStimInd = [];
end

try
    correctRespStruc(numRec).stimTypeArr = stimTypeArr;
catch
    correctRespStruc(numRec).stimTypeArr = [];
end
try
    correctRespStruc(numRec).stimTimeArr = stimTimeArr;
catch
    correctRespStruc(numRec).stimTimeArr = [];
end

try
    correctRespStruc(numRec).corrRespArr = corrRespArr; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).corrRespArr = [];
end



% new output variables (for skip sessions mostly)
try
    correctRespStruc(numRec).rewArr = rewArr; % for each reward, tells what kind (for skips, switches)
catch
    correctRespStruc(numRec).rewArr = [];
end

try
    correctRespStruc(numRec).punArr = punArr; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).punArr = [];
end



% new outputs

try
    correctRespStruc(numRec).rewToneSolSkipStimInd = rewToneSolSkipStimInd; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).rewToneSolSkipStimInd = [];
end

try
    correctRespStruc(numRec).rewToneSkipStimInd = rewToneSkipStimInd; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).rewToneSkipStimInd = [];
end

try
    correctRespStruc(numRec).rewSolSkipStimInd = rewSolSkipStimInd; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).rewSolSkipStimInd = [];
end

try
    correctRespStruc(numRec).rewPunSwitchStimInd = rewPunSwitchStimInd; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).rewPunSwitchStimInd = [];
end

try
    correctRespStruc(numRec).punRewSwitchStimInd = punRewSwitchStimInd; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
catch
    correctRespStruc(numRec).punRewSwitchStimInd = [];
end

try
    correctRespStruc(numRec).rewStimInd = rewStimInd; 
catch
    correctRespStruc(numRec).rewStimInd = [];
end

try
    correctRespStruc(numRec).punStimInd = punStimInd; 
catch
    correctRespStruc(numRec).punStimInd = [];
end

try
    correctRespStruc(numRec).punToneSkipStimInd = punToneSkipStimInd; 
catch
    correctRespStruc(numRec).punToneSkipStimInd = [];
end





clear correctRewStimInd correctStimInd corrLevPressLatency incorrectRewStimInd incorrectStimInd incorrectUnrewStimInd incorrLevPressLatency correctUnrewStimInd stimTypeArr stimTimeArr corrRespArr;

        
    end % end IF cond. for checking that file is a TXT file
end  % end FOR loop for looking through all data files on that day


for numSess = 1:length(correctRespStruc)
    animalCorrResp(numSess) = length(correctRespStruc(numSess).correctStimInd)/length(correctRespStruc(numSess).corrRespArr);
end
