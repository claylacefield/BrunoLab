function [correctRespStruc, event1, ev1time] = correctResp(day);

% pseudocode for script to compute % errors

% variables I want:
% array of correct responses and times
% array of incorrect responses and times
% array of correct rewarded responses and times
% array of correct unrewarded responses and times

% what I want to find
% - percent correct responses (both types) per timebin
% - to see accuracy of consecutive rewarded/unrewarded responses by order
% - to see latency of responses (correct rewarded vs. incorrect unrewarded)

% so in the previous spatDisc scripts, I split out all of the individual
% event types, but never made a specific cell array for all the even
% strings. This I need to do such, so that I can see if stim triggers are
% directly followed by lever presses.

% First, read in all the TXT file as a cell array
% then, search for stim triggers
% then, find a couple of things from each stimulus trigger
% a.) whether the subsequent response is correct:
% if strfind(fullCell(n+2), 'press' or 'REWARD')
% b.) the latency of the lever press, if any press
% [fullCell(n+3)-fullCell(n+1)] but str2double first

% NOTE: This script is VERY sensitive to the specific format of the data-
% if you add on some kind of header or otherwise shift the number of intro
% lines by odd numbers, this script will get confused about which lines of
% the cell array are events and which are event times. This can be solved
% by seeking the beginning of the event data in an unbiased fashion (by
% looking for a particular word, e.g. "START"), otherwise by seeing whether
% 
% cell can be cast as a double or not.

% ALSO: need to calculate error rates for consecutive stimuli
% and
% 1.) to find error rates based upon latency
% 2.)
% 3.)
% 4.)
% 5.)
% 6.)

%% FIND FOLDER FOR THAT DAY
% go to the correct folder for the desired day
folder = ['\\10.112.43.36\Public\clay\mouse behavior\2011\' day];

cd(folder);

currDir = dir;

numRec = 0;

%% LOOK THROUGH ALL FILES IN THE FOLDER FOR THIS DAY
for i = 30:length(currDir);



    %%  LOOK FOR TEXT FILES OF DATA AND PARSE FOR EVENTS AND EVENT TIMES
    if strfind(currDir(i).name, '.txt');    % make sure file is .txt, thus data
        numRec = numRec + 1;
        file = currDir(i).name;

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
        fullCell= textread(file,'%s', 'delimiter', '\n');   % read in whole file as cell array
        %numEvents = length(fullCell)/2;

        % scan fullCell of text data to look for particular events
        for txtInd = 3:2:(length(fullCell)-5)
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

                end % end IF cond. looking for top/unrewarded stimuli

            end % end IF cond. looking for bottom vs. top stimuli

        end  % end FOR loop looking through all events and times in data cell array

        %% SAVE VARIABLES INTO A STRUC
        % save important info into a data structure
        try
            correctRespStruc(numRec).name = currDir(i).name;
        catch
        end
        try
            correctRespStruc(numRec).correctRewStimTime = correctRewStimTime;
        catch
        end
        try
            correctRespStruc(numRec).correctStimTime = correctStimTime;
        catch
        end
        try
            correctRespStruc(numRec).corrLevPressLatency = corrLevPressLatency;
        catch
        end
        try
            correctRespStruc(numRec).incorrectRewStimTime = incorrectRewStimTime;
        catch
        end
        try
            correctRespStruc(numRec).incorrectStimTime = incorrectStimTime;
        catch
        end
        try
            correctRespStruc(numRec).incorrectUnrewStimTime = incorrectUnrewStimTime;
        catch
        end
        try
            correctRespStruc(numRec).incorrLevPressLatency = incorrLevPressLatency;
        catch
        end
        try
            correctRespStruc(numRec).correctUnrewStimTime = correctUnrewStimTime;
        catch
        end
        try
            correctRespStruc(numRec).stimTypeArr = stimTypeArr;
        catch
        end
        try
            correctRespStruc(numRec).stimTimeArr = stimTimeArr;
        catch
        end
        try
            correctRespStruc(numRec).corrRespArr = corrRespArr; % same dimen as stimTypeArr and 1 for correct, 0 for incorrect
        catch
        end
        
        clear correctRewStimTime correctStimTime corrLevPressLatency incorrectRewStimTime incorrectStimTime incorrectUnrewStimTime incorrLevPressLatency correctUnrewStimTime stimTypeArr stimTimeArr corrRespArr;

        %%
    end % end IF cond. for checking that file is a TXT file
end  % end FOR loop for looking through all data files on that day




