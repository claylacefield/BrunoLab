function [spatDiscGrpStruc] = spatDiscGrp(spatDiscStruc)

%% DESCRIPTION
% "spatDiscGrp" is a function that operates on the output structure for the "spatDisc"
% script, a data structure consisting of extracted events for each animal
% for that day, and plots running histograms of performance over the
% session for each
%
% USAGE:
% [spatDiscGrpStruc] = spatDiscGrp(spatDiscStruc)
% Have spatDiscStruc for that day open, or open the structure saved from a
% previous run of spatDisc.m
% Yields structure with overall and binned discrimination indices for all
% animals.
%
% NOTE: times are in milliseconds
%
% 013011: as of right now, this script just plots out the performance of
% the animal over the session, but I need to have it output the overall
% percentages for XL spreadsheets.


%% START PROGRAM
% initialize variables

minBin = 1;  % time base over which to calculate histograms
binFracMouse= zeros(length(spatDiscStruc), 20/minBin);
binFracMouse2= zeros(length(spatDiscStruc), 20/minBin);
bin = minBin*60000; % bin size, in ms

%% EXTRACT EVENT TIMES FROM STRUCTURE
% loop through each animal and calculate performance
for i=1:length(spatDiscStruc)       % for every animal from this day, load variables from structure into workspace
    rewStim=spatDiscStruc(i).rewStim;   % extracts times of rewarded stimuli
    rewStim2(i)=length(rewStim);    % #rewarded stimuli
    reward=spatDiscStruc(i).reward;     % times of rewards
    numRew(i)=length(reward);   % #rewards
    fracRew(i)=length(reward)/length(rewStim);  % percent correct rewards
    unrewStim=spatDiscStruc(i).unrewStim;   % times of unrewarded stimuli
    unrewStim2(i)=length(unrewStim);    % # unrewarded stimuli
    unrewLev=spatDiscStruc(i).unrewLev;     % times of unrewarded lever presses
    numUnrewLev(i)=length(unrewLev);    % # unrewarded lever presses
    fracUnrewLev(i)=length(unrewLev)/length(unrewStim);     % percent unrewarded lever presses
    numTrig(i)=length(rewStim)+length(unrewStim);  % # stimulus triggers
    discInd(i) = fracRew(i) - fracUnrewLev(i);   % DISCRIMINATION INDEX (over entire session)



%% DISCRIMINATION INDEX: METHOD #1 (CUMULATIVE)
    % HISTOGRAMS OF EVENTS FOR EACH TIMEBIN
    % this section plots histograms of performance over the entire behavior
    % period (added ~3/29/10)

    for j=1:(20/minBin)  % for each timebin in trial
        
        % rewarded stimuli
        n=0; m=0;
        binRew = find(reward <= j*bin);   % finds all rewards up to this time (thus cumulative)
        binRewStim = find(rewStim <= j*bin);  % finds all reward opportunities up to this time
        n = length(binRew); % # rewards obtained in this timebin
        m = length(binRewStim); % # rewarded stimuli in this timebin
        if m ~= 0
            binFrac(j) = n/m;   % fraction of rewards per rewarded stim (cumulative)
        else
            binFrac(j) = 0; % if there were no rewarded stimuli, keeps from crashing
        end
        
        % unrewarded stimuli
        p=0; q=0;
        binUnrew = find(unrewLev <= j*bin);   % finds all unrewarded lever presses up to this time
        binUnrewStim = find(unrewStim <= j*bin);
        p = length(binUnrew);   % # unrewarded lever presses
        q = length(binUnrewStim);   % # unrewarded stimuli
        if q ~= 0
            binFrac2(j) = p/q;   % fraction of rewards per rewarded stim (cumulative)
        else
            binFrac2(j) = 0; % if there were no unrewarded stimuli, keeps from crashing
        end
        
        % discrimination index
        binFrac3(j)= binFrac(j)-binFrac2(j);    % CUMULATIVE DISCRIMINATION INDEX
        binDiff(j) = n-p;
    end

    binFracMouse(i, :)= binFrac3;   % saves cumulative discrimination index for all timebins for each animal

    % start plot
    figure;
    subplot(4,2,1);
    bar(binFracMouse(i,:));     % plot the cumulative discrimination index (= %correct - %incorrect unrewarded)
    title(spatDiscStruc(i).name);

%% DISCRIMINATION INDEX: METHOD #2
    %new way of calculating discrimination index (for time bins of
    %arbitrary length, defined early in the script)

    for k=1:(20/minBin)        % for each time segment (defined at start) of the 20 min trial
        
        % rewarded trials
        a=0; b=0;
        binRew2 = find(reward > (k-1)*bin & reward <= k*bin);   % output rewards occuring within this timebin
        binRewStim2 = find(rewStim > (k-1)*bin & rewStim <= k*bin);
        a = length(binRew2);    % # rewarded lever presses
        b = length(binRewStim2);    % # rewarded stimuli
        
        binFrac4(k) = a/b;  % fraction of rewarded lever presses for this timebin
        
        
        % unrewarded trials
        c=0; d=0;
        binUnrew2 = find(unrewLev > (k-1)*bin & unrewLev <= k*bin);
        binUnrewStim2 = find(unrewStim > (k-1)*bin & unrewStim <= k*bin);
        c = length(binUnrew2);  % # unrewarded lever presses
        d = length(binUnrewStim2);  % # unrewarded stimuli
        binFrac5(k) = c/d;  % fraction of unrewarded lever presses for this timebin
        
        % discrimination index (method #2)        
        binFrac6(k)= binFrac4(k)-binFrac5(k);   % DISCRIMINATION INDEX
        binDiff2(k) = a-c;

    end

    binFracMouse2(i, :)= binFrac6;  % save disc index into matrix for all animals
    
    % (not using this right now to save individual stats by animal into
    % struc)
    % spatDiscGrpStruc(i).discInd = discInd(i);
    % spatDiscGrpStruc(i).binFracMouse2 = binFracMouse2(i,:);

    subplot(4,2,3);
    bar(binFracMouse2(i,:));
    title('Discrimination Index (method 2)');

    subplot(4,2,5);
    bar(binFrac4, 'g');
    title('Fraction rewarded lever presses');

    subplot(4,2,7);
    bar(binFrac5, 'r');
    title('Fraction unrewarded lever presses');

    subplot(4,2,2);
    bar(binDiff);
    title('Discrimination Index');

    subplot(4,2,4);
    bar(binDiff2);
    title('Discrimination Index');

    %%

end

%%
% stim=[spatDiscStruc.stim];
% figure; hist(stim);
% rew=[spatDiscStruc.reward];
% figure; hist(rew);

% save results for all animals into structure for this day
spatDiscGrpStruc.discInd = discInd; % to save overall disc index for all animals
spatDiscGrpStruc.binFracMouse = binFracMouse;  % to save cumulative disc index in bins for all animals
spatDiscGrpStruc.binFracMouse2 = binFracMouse2; % to save normal disc index in bins for all animals

spatDiscGrpStruc.rewStim2 = rewStim2;    % #rewarded stimuli
spatDiscGrpStruc.numRew = numRew;   % #rewards
spatDiscGrpStruc.fracRew = fracRew;  % percent correct rewards
spatDiscGrpStruc.unrewStim2 = unrewStim2;    % # unrewarded stimuli
spatDiscGrpStruc.numUnrewLev = numUnrewLev;    % # unrewarded lever presses
spatDiscGrpStruc.fracUnrewLev = fracUnrewLev;     % percent unrewarded lever presses
spatDiscGrpStruc.numTrig = numTrig;  % # stimulus triggers

discInd= fracRew./fracUnrewLev;
