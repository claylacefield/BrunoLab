function [spatDiscStruc] = spatDiscSing(file);

% NOTE that this program will change depending upon the computer it's used
% on, because of the location of the data files

%folder = ['C:\Users\Clay\Documents\Bruno lab\Mouse Behavior\behav data\data\2010\' day];

%cd(folder);

%currDir = dir;

%numRec=0;


ir=0;
trig=0;
unrewStimNum=0;
rewStimNum=0;
rewNum=0;
noStimLevNum=0;
unrewLevNum=0;
levNum=0;


fullCell= textread(file,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;
for j=4:2:(length(fullCell)-1);
    event=fullCell{j};
    timeChar = fullCell{j+1};
    time= str2double(timeChar);
    if strfind(event, 'IR');
        ir = ir+1;  % increment num IR beam breaks
        bmBrk(ir) = time;
    elseif strfind(event, 'trigger');
        trig = trig+1;  % count number of stimulus triggers (from IR beam break)
        stim(trig)=time;    % log times of stim triggers (all types)
        if strfind(event, 'rewarded');
            rewStimNum = rewStimNum +1; % count number of rewarded stimuli
            rewStim(rewStimNum)=time;       % times of rewarded stimuli
        else
            unrewStimNum = unrewStimNum +1;     % count number of unrewarded stimuli
            unrewStim(unrewStimNum) = time;         % times of unrew stims
        end;
    elseif strfind(event, 'REWARD!');   %find rewards
        rewNum = rewNum+1;  % count number of rewarded lever presses
        reward(rewNum)=time;    % times of rewarded lev presses
    elseif strfind(event, 'lever');
        levNum = levNum+1;      % count all bad lever presses (no stim and unrew)
        levTime(levNum)=time;
        if strfind(event, 'stim');
            noStimLevNum = noStimLevNum +1;     % count no stim lever presses
            noStimLev(noStimLevNum)=time;
        else
            unrewLevNum = unrewLevNum +1;   % and all rest will be unrew lev presses
            unrewLev(unrewLevNum) = time;
        end;
    end;
end;

