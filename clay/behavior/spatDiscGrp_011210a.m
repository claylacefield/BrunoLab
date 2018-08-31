

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
end

% stim=[spatDiscStruc.stim];
% figure; hist(stim);
% rew=[spatDiscStruc.reward];
% figure; hist(rew);

discInd= fracRew./fracUnrewLev;
