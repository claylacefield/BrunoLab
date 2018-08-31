function spatDiscGrp(spatDiscStruc)

binFracMouse= zeros(10, 20);

minBin = 2;  % time base over which to calculate histograms
binFracMouse2= zeros(10, 20/minBin);
bin = minBin*60000;   

%%
for i=1:length(spatDiscStruc)
    rewStim=spatDiscStruc(i).rewStim;
    rewStim2(i)=length(rewStim);
    reward=spatDiscStruc(i).reward;
    numRew(i)=length(reward);
    fracRew(i)=length(reward)/length(rewStim);
    unrewStim=spatDiscStruc(i).unrewStim;
    unrewStim2(i)=length(unrewStim);
    unrewLev=spatDiscStruc(i).unrewLev;
    numUnrewLev(i)=length(unrewLev);
    fracUnrewLev(i)=length(unrewLev)/length(unrewStim);
    numIRbrk(i)=length(rewStim)+length(unrewStim);
    
    % this section plots histograms of performance over the entire behavior
    % period (added ~3/29/10)
    
%%    
    for j=1:20
        n=0; m=0;
    binRew = find(reward <= j*60000);
    binRewStim = find(rewStim <= j*60000);
    n = length(binRew);
    m = length(binRewStim);
    binFrac(j) = n/m;
    
        p=0; q=0;
    binUnrew = find(unrewLev <= j*60000);
    binUnrewStim = find(unrewStim <= j*60000);
    p = length(binUnrew);
    q = length(binUnrewStim);
    binFrac2(j) = p/q;
    binFrac3(j)= binFrac(j)/binFrac2(j);
    end
    
    binFracMouse(i, :)= binFrac3;
    figure;
    subplot(1,2,1);
    bar(binFracMouse(i,:));
    title(spatDiscStruc(i).name);
    
%%    
%new way of calculating discrimination index
        for k=1:(20/minBin)        % for each time segment (defined at start) of the 20 min trial
        a=0; b=0;
        binRew2 = find(reward >= (k-1)*bin & reward <= j*bin);   % gives 
        binRewStim2 = find(rewStim >= (k-1)*bin & rewStim <= k*bin);
        a = length(binRew2);
        b = length(binRewStim2);
        binFrac4(k) = a/b;

        c=0; d=0;
        binUnrew2 = find(unrewLev >= (k-1)*bin & unrewLev <= k*bin);
        binUnrewStim2 = find(unrewStim >= (k-1)*bin & unrewStim <= k*bin);
        c = length(binUnrew2);
        d = length(binUnrewStim2);
        binFrac5(k) = c/d;
        binFrac6(k)= binFrac4(k)/binFrac5(k);

    end

    binFracMouse2(i, :)= binFrac3;
    subplot(1,2,2);
    bar(binFracMouse2(i,:));
%%    
    
end

%%
% stim=[spatDiscStruc.stim];
% figure; hist(stim);
% rew=[spatDiscStruc.reward];
% figure; hist(rew);

discInd= fracRew./fracUnrewLev;
