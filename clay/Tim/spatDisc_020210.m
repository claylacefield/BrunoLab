function [spatDiscStruc] = spatDisc(day);



folder = ['C:\Documents and Settings\Clay\My Documents\Bruno Lab\Mouse Behavior\behav data\data\' day];

cd(folder);

currDir = dir;

numRec=0;

for i = 3:length(currDir);
    ir=0;
    trig=0;
    unrew=0;
    rewStimNum=0;
    rewNum=0;
    noStimLevNum=0;
    unrewLevNum=0;
    levNum=0;

    if strfind(currDir(i).name, '.txt');    % make sure file is .txt, thus data
        numRec = numRec + 1;
        file = currDir(i).name;
        %[fid,message] = fopen(file, 'rt');  % open data .txt file for reading
        %fullCell = textscan(fid, 'format');
        %fclose(fid);    % close the file after reading
        fullCell= textread(file,'%s', 'delimiter', '\n');   % read in whole file as cell array
        %numEvents = length(fullCell)/2;
        for j=1:2:(length(fullCell)-1);
            event=fullCell{j};
            timeChar = fullCell{j+1};
            time= str2double(timeChar);
            if strfind(event, 'IR');
                ir = ir+1;  % increment num IR beam breaks
                bmBrk(ir) = time;
            elseif strfind(event, 'trigger');
                trig = trig+1;
                stim(trig)=time;
                if strfind(event, 'rewarded');
                    rewStimNum = rewStimNum +1;
                    rewStim(rewStimNum)=time;
                else
                    unrew = unrew +1;
                    unrewStim(unrew) = time;
                end;
            elseif strfind(event, 'REWARD!');
                rewNum = rewNum+1;
                reward(rewNum)=time;
            elseif strfind(event, 'lever');
                levNum = levNum+1;
                levTime(levNum)=time;
                if strfind(event, 'stim');
                    noStimLevNum = noStimLevNum +1;
                    noStimLev(noStimLevNum)=time;
                else
                    unrewLevNum = unrewLevNum +1;
                    unrewLev(unrewLevNum) = time;
                end;
            end;
        end;

        % save important info into a data structure
        try
            spatDiscStruc(numRec).name = currDir(i).name;
        catch
        end
        try
            spatDiscStruc(numRec).bmBrk = bmBrk;
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


        clear bmBrk stim rewStim unrewStim reward levTime noStimLev unrewLev;

    end;
end;

save(['C:\Documents and Settings\Clay\My Documents\Bruno Lab\Mouse Behavior\behav data\data\matlab\' day], 'spatDiscStruc');
% NOTES: need to put in section to save structure for each day's recordings