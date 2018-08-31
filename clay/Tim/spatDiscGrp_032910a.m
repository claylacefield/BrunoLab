binFracMouse= zeros(10, 20);

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
    bar(binFracMouse(i,:));
end

% stim=[spatDiscStruc.stim];
% figure; hist(stim);
% rew=[spatDiscStruc.reward];
% figure; hist(rew);

discInd= fracRew./fracUnrewLev;
