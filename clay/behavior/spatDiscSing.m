%function [spatDiscStruc] = spatDiscSing(file);

% 071210: made this program in order to analyze data from closedEconomy;
% it has most of the features of the spatDisc script but allows one to set
% time increments for histograms more flexibly and define the source file

% NOTE that this program will change depending upon the computer it's used
% on, because of the location of the data files

%folder = ['C:\Users\Clay\Documents\Bruno lab\Mouse Behavior\behav data\data\2010\' day];

%cd(folder);

%currDir = dir;

%numRec=0;

% Initialize a few variables
ir=0;
trig=0;
unrewStimNum=0;
rewStimNum=0;
rewNum=0;
noStimLevNum=0;
unrewLevNum=0;
levNum=0;

% Read in the behavioral data from the file described in the filepath
fullCell= textread(file,'%s', 'delimiter', '\n');   % read in whole file as cell array
txtLength = length(fullCell);

% Go through and parse the txt file for diff events and their times
% NOTE: may have to start the parsing at diff points depending upon which
% header information I put into the txt file

for j=3:2:(length(fullCell)-1);
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

binSize = 120;  % time base over which to calculate histograms (in minutes)
maxTimeStr = fullCell{txtLength};  % records the last entry, which is the time of the final event
maxTime = str2double(maxTimeStr);
maxMin = maxTime/1000/60;    % converts this to minutes
maxRound = maxTime-rem(maxTime, 60000); % max time, rounded to nearest minute
maxRoundMin = maxRound/60000;
if rem(maxRoundMin, binSize) ~= 0;
    maxRoundMin = maxRoundMin - 1;
end
numBins = maxRoundMin/binSize;

%binFracMouse= zeros(10, maxRoundMin/binSize);
bin = binSize*60000;

% now compile histograms of performance over time
n = zeros(numBins, 1);
m = zeros(numBins, 1);
p = zeros(numBins, 1);
q = zeros(numBins, 1);
binFrac = zeros(numBins, 1);
binFrac2 = zeros(numBins, 1);
binFrac3 = zeros(numBins, 1);

for j=1:numBins      % for each time segment (defined at start) of the 20 min trial
    %n=0; m=0;
    binRew = find(reward >= (j-1)*bin & reward <= j*bin);   % gives
    binRewStim = find(rewStim >= (j-1)*bin & rewStim <= j*bin);
    n(j) = length(binRew);
    m(j) = length(binRewStim);
    binFrac(j) = n(j)/m(j);

    %p=0; q=0;
    binUnrew = find(unrewLev >= (j-1)*bin & unrewLev <= j*bin);
    binUnrewStim = find(unrewStim >= (j-1)*bin & unrewStim <= j*bin);
    p(j) = length(binUnrew);
    q(j) = length(binUnrewStim);
    binFrac2(j) = p(j)/q(j);
    binFrac3(j)= binFrac(j)/binFrac2(j);
end

figure;
bar(binFrac);
title('fraction rewarded lever presses');
figure;
bar(binFrac2);
title('fraction unrewarded lever presses');
figure;
bar(binFrac3);
title('discrimination index');