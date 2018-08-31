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
% [fullCell(n+3)-fullCell(n+1)] but str2doub first


% NOTE: This script is VERY sensitive to the specific format of the data-
% if you add on some kind of header or otherwise shift the number of intro
% lines by odd numbers, this script will get confused about which lines of
% the cell array are events and which are event times. This can be solved
% by seeking the beginning of the event data in an unbiased fashion (by
% looking for a particular word, e.g. "START"), otherwise by seeing whether
% cell can be cast as a double or not.


% scan fullCell of text data to look for particular events
for txtInd = 3:2:(length(fullCell)-1)
    % First, look for correct responses
    if strfind(fullCell(txtInd), 'bottom')
        if strfind(fullCell(txtInd+2), 'REWARD')
            correctRewStimTime(corrRewInd) = str2doub(fullCell(txtInd+1));
            corrRewInd = corrRewInd + 1;
            correctStimTime(corrInd) = str2doub(fullCell(txtInd+1));
            corrInd = corrInd + 1;
        % else if incorrect witholding press, add to incorrect array
        else incorrectRewStimTime(incorrRewInd) = str2doub(fullCell(txtInd+1));
            incorrRewInd = incorrRewInd + 1;
            incorrectStimTime(incorrInd) = str2doub(fullCell(txtInd+1));
            incorrInd = incorrInd + 1;
        end % end IF cond. looking for bottom/rewarded stimuli
    else
        if strfind(fullCell(txtInd), 'top')
            if strfind(fullCell(txtInd+2), 'unrewarded')
                incorrectUnrewStimTime(incorrUnrewInd) = str2doub(fullCell(txtInd+1));
                incorrUnrewInd = incorrUnrewInd + 1;
                incorrectStimTime(incorrInd) = str2doub(fullCell(txtInd+1));
                incorrInd = incorrInd + 1;
            else
                correctUnrewStimTime(corrUnrewInd) = str2doub(fullCell(txtInd+1));
                corrUnrewInd = corrUnrewInd + 1;
                correctStimTime(corrInd) = str2doub(fullCell(txtInd+1));
                corrInd = corrInd + 1;
            end % end IF cond. looking for outcome of unrew stim trial
        end % end IF cond. looking for top/unrewarded stimuli
    end % end IF cond. looking for bottom vs. top stimuli
end  % end FOR loop looking through all events and times in data cell array







