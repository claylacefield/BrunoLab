function spatDiscGrp(spatDiscStruc)

binFracMouse= zeros(length(spatDiscStruc), 20);

minBin = 1;  % time base over which to calculate histograms
binFracMouse2= zeros(length(spatDiscStruc), 20/minBin);
bin = minBin*60000;

%%
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
    numIRbrk(i)=length(rewStim)+length(unrewStim);  % # stimulus triggers

    % this section plots histograms of performance over the entire behavior
    % period (added ~3/29/10)

%%
    for j=1:20  % for each timebin in trial
        n=0; m=0;
        binRew = find(reward <= j*60000);   % finds all rewards up to this time (thus cumulative)
        binRewStim = find(rewStim <= j*60000);  % finds all reward opportunities up to this time
        n = length(binRew);
        m = length(binRewStim);
        if m ~= 0
        binFrac(j) = n/m;   % fraction of rewards per rewarded stim (cumulative)
        else
            binFrac(j) = 0;
        end

        p=0; q=0;
        binUnrew = find(unrewLev <= j*60000);   % finds all unrewarded lever presses up to this time
        binUnrewStim = find(unrewStim <= j*60000);
        p = length(binUnrew);
        q = length(binUnrewStim);
        if q ~= 0
        binFrac2(j) = p/q;   % fraction of rewards per rewarded stim (cumulative)
        else
            binFrac2(j) = 0;
        end
        
        binFrac3(j)= binFrac(j)-binFrac2(j);
        binDiff(j) = n-p;
    end

    binFracMouse(i, :)= binFrac3;
    figure;
    subplot(4,2,1);
    bar(binFracMouse(i,:));
    title(spatDiscStruc(i).name);

%%
    %new way of calculating discrimination index (for time bins of
    %arbitrary length, defined early in the script)
    
    for k=1:(20/minBin)        % for each time segment (defined at start) of the 20 min trial
        a=0; b=0;
        binRew2 = find(reward > (k-1)*bin & reward <= k*bin);   % output rewards occuring within this timebin
        binRewStim2 = find(rewStim > (k-1)*bin & rewStim <= k*bin);
        a = length(binRew2);
        b = length(binRewStim2);
        binFrac4(k) = a/b;  % fraction of rewarded lever presses for this timebin
        

        c=0; d=0;
        binUnrew2 = find(unrewLev > (k-1)*bin & unrewLev <= k*bin);
        binUnrewStim2 = find(unrewStim > (k-1)*bin & unrewStim <= k*bin);
        c = length(binUnrew2);
        d = length(binUnrewStim2);
        binFrac5(k) = c/d;  % fraction of unrewarded lever presses for this timebin
        binFrac6(k)= binFrac4(k)-binFrac5(k);
        binDiff2(k) = a-c;

    end

    binFracMouse2(i, :)= binFrac6;
    subplot(4,2,3);
    bar(binFracMouse2(i,:));
    subplot(4,2,5); 
    bar(binFrac4, 'g'); 
    subplot(4,2,7);
    bar(binFrac5, 'r');
    subplot(4,2,2);
    bar(binDiff);
    subplot(4,2,4);
    bar(binDiff2);
%%

end

%%
% stim=[spatDiscStruc.stim];
% figure; hist(stim);
% rew=[spatDiscStruc.reward];
% figure; hist(rew);

discInd= fracRew./fracUnrewLev;
