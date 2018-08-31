


rew4 = dendriteBehavStruc.rewTime4Ca;
rew1 = dendriteBehavStruc.rewTime1Ca;

baseline = 0;

if baseline == 1
    
    baseFrame = 6;
    
    for i = 1:size(rew1,2)
        base1 = rew1(baseFrame,i);
        rew1b(:,i) = rew1(:,i)-base1;
    end
    
    for i = 1:size(rew4,2)
        base4 = rew4(baseFrame,i);
        rew4b(:,i) = rew4(:,i)-base4;
    end
    
else
    rew1b = rew1;
    rew4b = rew4;
end
    

xAx = -2:0.25:6;

figure; 
line([0 0], [-0.3 0.6], 'Color', [0.2 0.2 0.2]);
hold on; 
plot(xAx, rew1b,'b'); 
plot(xAx, rew4b, 'r');


%% plot calcium by trial color

figure;
hold on;
colors = jet(size(rew1,2));
for numTrial = 1:size(rew1,2)
    plot(rew1(:,numTrial), 'Color', colors(numTrial,:));
end


%% plot early vs late trials

rew1e = rew1(:,1:20);
rew1l = rew1(:,50:70);

semE = std(rew1e, 0,2)/sqrt(20);
semL = std(rew1l,0,2)/sqrt(20);


figure;
hold on;
errorbar(mean(rew1e,2),semE,'b');
errorbar(mean(rew1l,2),semL,'r');













