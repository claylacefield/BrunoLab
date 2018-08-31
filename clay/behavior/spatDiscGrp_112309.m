

for i=1:length(spatDiscStruc)
    rewStim=spatDiscStruc(i).rewStim;
    reward=spatDiscStruc(i).reward;
    fracRew(i)=length(reward)/length(rewStim);
    unrewStim=spatDiscStruc(i).unrewStim;
    unrewLev=spatDiscStruc(i).unrewLev;
    fracUnrewLev(i)=length(unrewLev)/length(unrewStim);
end

stim=[spatDiscStruc.stim];
figure; hist(stim);
rew=[spatDiscStruc.reward];
figure; hist(rew);
