function [h,p] = fitRewDelPks()

% Clay 090617

% (on laptop)
load('C:\Users\Clay\Documents\Bruno lab\dendritePaper\frameData\rewDelayGroup_44goodSess_012115a.mat');

% calc 2nd pks for diff rewDelays
[pk2rew1ind, pk2rew2ind, pk2rew3ind] = scatter1st2ndPk(outStruc);

t = 1:3;
t2 = [1 3];

% fit line for all rewDelay sessions
for i = 1:length(pk2rew1ind)
    
    a = [pk2rew1ind(i) pk2rew2ind(i) pk2rew3ind(i)]; % rewDelay 2nd pk times per 
    
    p = polyfit(t,a,1); % linear fit
    y2 = polyval(p,t2);
    
    m(i) = diff(y2)/diff(t2); % slope of linear fit
    
end

[h,p,ci,stats] = ttest(m);

% figure;
% plot(t,a,'o',t2,y2);

