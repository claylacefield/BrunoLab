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


for n = 3:2:(length(fullCell)-1)
    % First, look for 
    if strfind(fullCell(n), 'bottom')
        if strfind(fullCell(n+2), 'REWARD')
            
