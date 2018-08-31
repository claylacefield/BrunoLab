function [spatDiscStruc] = spatDisc(day);

% NOTE that this program will change depending upon the computer it's used
% on, because of the location of the data files

%%
folder = ['\\10.112.43.36\Public\clay\mouse behavior\2011\' day];

cd(folder);

currDir = dir;

numRec=0;

%%
for i = 3:length(currDir);
    lev=0;
    trig=0;
    unrew=0;
    rewStimNum=0;
    rewNum=0;
    noStimLevNum=0;
    unrewLevNum=0;
    levNum=0;
    
%%
    if strfind(currDir(i).name, '.txt');    % make sure file is .txt, thus data
        numRec = numRec + 1;
        file = currDir(i).name;
        %[fid,message] = fopen(file, 'rt');  % open data .txt file for reading
        %fullCell = textscan(fid, 'format');
        %fclose(fid);    % close the file after reading
        fullCell= textread(file,'%s', 'delimiter', '\n');   % read in whole file as cell array
        %numEvents = length(fullCell)/2;
        for j=3:2:(length(fullCell)-1);     % for all events in the recording
            event=fullCell{j};
            timeChar = fullCell{j+1};
            time= str2double(timeChar);
            if strfind(event, 'start');
                lev = lev+1;  % increment num lev beam breaks
                levPress(lev) = time;   % and record the times of each
            elseif strfind(event, 'trigger');   % finds stimulus events of both types (rew and unrew)
                trig = trig+1;
                stim(trig)=time;    % and record times
                if strfind(event, 'rewarded');  % finds rewarded stimulus triggers
                    rewStimNum = rewStimNum +1;
                    rewStim(rewStimNum)=time;
                    
                    % this needs to convert from cell array to logical to
                    % work (013011)
%                     if strfind(fullCell(j+2), 'REWARD'); % new section 112210 to record correct presses
%                         correctRew(rewStimNum)= 1; 
%                     else
%                         correctRew(rewStimNum)= 0; 
%                     end
                else
                    unrew = unrew +1;   % finds unrewarded stimulus triggers
                    unrewStim(unrew) = time;
                    
                    % this needs to convert from cell array to logical to
                    % work (013011)
%                     if strfind(fullCell(j+2), 'unrewarded lever press'); % new section 112210 to record incorrect presses
%                         incorrectUnrew(unrew)= 1; 
%                     else
%                         incorrectUnrew(unrew)= 0; 
%                     end
                end;
            elseif strfind(event, 'REWARD!');   % finds rewards (lever presses during rewarded stim)
                rewNum = rewNum+1;
                reward(rewNum)=time;
            elseif strfind(event, 'lever');  % finds both unrewarded and nostim lever presses
                levNum = levNum+1;
                levTime(levNum)=time;
                if strfind(event, 'stim');  % finds nostim lever presses
                    noStimLevNum = noStimLevNum +1;
                    noStimLev(noStimLevNum)=time;
                else
                    unrewLevNum = unrewLevNum +1;   % finds unrewarded lever presses
                    unrewLev(unrewLevNum) = time;
                end;    % END IF for nonrewarded lever presses (during unrew stim or nostim)
            end;    % END IF for finding diff types of events
        end;

%%
        % save important info into a data structure
        try
            spatDiscStruc(numRec).name = currDir(i).name;
        catch
        end
        try
            spatDiscStruc(numRec).levPress = levPress;
        catch
        end
        try
            spatDiscStruc(numRec).stim = stim;
        catch
        end
        try
            spatDiscStruc(numRec).rewStim = rewStim;
        catch
        end
        try
            spatDiscStruc(numRec).unrewStim = unrewStim;
        catch
        end
        try
            spatDiscStruc(numRec).reward = reward;
        catch
        end
        try
            spatDiscStruc(numRec).levTime = levTime;
        catch
        end
        try
            spatDiscStruc(numRec).noStimLev = noStimLev;
        catch
        end
        try
            spatDiscStruc(numRec).unrewLev = unrewLev;
        catch
        end

%%
        clear levPress stim rewStim unrewStim reward levTime noStimLev unrewLev;

    end;
end;

%%
save(['C:\Documents and Settings\Clay\My Documents\Bruno Lab\Mouse Behavior\behav data\data\matlab\' day], 'spatDiscStruc');
% NOTES: need to put in section to save structure for each day's recordings