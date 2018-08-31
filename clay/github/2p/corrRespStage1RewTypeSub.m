function [rewArrVal, varargout] = corrRespStage1RewTypeSub(fullCell, txtInd, rewType)



% rew1 = normal mouse rew
% rew2 = rew tone skip
% rew3 = punRew switch (none present)
% rew4 = random rew
% rew5 = solSkip
% rew6 = rewToneSolSkip

% punRew switch tone skip ("rew 7")
% punRewSolSkip times ("rew 8")
% punRewToneSolSkip times ("rew 9")
% normal reward times based upon arduino time ("rew 10")
% "rew 11" = time of normal exp rewards
% "rew 12" = time of start rewards

% new 022617
% rew13 = randRew tone skip
% rew14 = experimenter tone skip
% and add these to normal correctResp scripts
% (these should be only ones that might affect rewArr lengths)

%%

ev1time = str2double(fullCell{txtInd+1});
event2 = fullCell{txtInd+2};
ev2time = str2double(fullCell{txtInd+3});
event3 = fullCell{txtInd+4}; % to see if cues are skipped
ev3time = str2double(fullCell{txtInd+5});
event4 = fullCell{txtInd+6};
ev4time = str2double(fullCell{txtInd+7});
event5 = fullCell{txtInd+8};
ev5time = str2double(fullCell{txtInd+9});

% see if reward is normal or otherwise
if strfind(event2, 'reward tone skip')
    % tabulate skipped cue trials (may want to move this before previous section)
    
    
    % if solenoid is skipped, don't count in rewArr
    if strfind(event3, 'reward solenoid skip');
        
        if rewType == 1
            rewArrVal = 6;  % "2" is reward tone skip in rewArr
%         elseif rewType == 2
%             
%         elseif rewType == 3
        end

    else    % otherwise do count in reward list
        if rewType == 1
            rewArrVal = 2;  % "2" is reward tone skip in rewArr
%         elseif rewType == 2
%             
%         elseif rewType == 3
            
        end
    end
    
elseif strfind(event2, 'reward solenoid skip');
    if rewType == 1
        rewArrVal = 5;  % "2" is reward tone skip in rewArr
        %rew5time = ev1time;
%     elseif rewType == 2
%         
%     elseif rewType == 3
    end
    
else % for normal reward

    if rewType == 1
        rewArrVal = 1;  % "1" is normal reward in rewArr
    elseif rewType == 2
        rewArrVal = 4; % "4" is rand rew
    elseif rewType == 3
        rewArrVal = 11;  % "11" is exp rew
    end

end