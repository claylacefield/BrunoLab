


% Plotting script for data from dendriteBehavAnalysis

startX = 0; % 2*hz;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);

figure;

subplot(3,3,1); %
plot(xAx, dendriteBehavStruc.rewardsCaAvg); 
title('rewards (b), punishments (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.punTimeCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,2);
plot(xAx, dendriteBehavStruc.corrRewIndCaAvg); 
title('correct rew trials (b), incorr rew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.incorrRewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,3);
plot(xAx, dendriteBehavStruc.corrUnrewIndCaAvg); 
title('correct unrew trials (b), incorr unrew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.incorrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,4);
plot(xAx, dendriteBehavStruc.corrRewIndCaAvg); 
title('correct rew (b), and unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.corrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,5);
plot(xAx, dendriteBehavStruc.incorrRewIndCaAvg); 
title('incorrect rew (b), and unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.incorrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,6);
plot(xAx, dendriteBehavStruc.incorrRewIndCaAvg); 
title('incorrect rew (b), and correct unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.corrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,7);
plot(xAx, dendriteBehavStruc.corrRewIndCaAvg); 
title('correct rew (b), and incorrect unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.incorrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,8);
plot(xAx, dendriteBehavStruc.corrFirstContactTimesCaAvg); 
title('correct (b), and incorrect rew trial (r) first whisker contacts');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, dendriteBehavStruc.incorrFirstContactTimesCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;
