


% Plotting script for data from dendriteBehavAnalysis

startX = 0; % 2*hz;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);


rewardsCaAvg = batchDendStruc4hz.rewardsCaAvg;
punTimeCaAvg = batchDendStruc4hz.punTimeCaAvg;
corrRewIndCaAvg = batchDendStruc4hz.corrRewIndCaAvg;
incorrRewIndCaAvg = batchDendStruc4hz.incorrRewIndCaAvg;
corrUnrewIndCaAvg = batchDendStruc4hz.corrUnrewIndCaAvg;
incorrUnrewIndCaAvg = batchDendStruc4hz.incorrUnrewIndCaAvg;
corrFirstContactTimesCaAvg = batchDendStruc4hz.corrFirstContactTimesCaAvg;
incorrFirstContactTimesCaAvg = batchDendStruc4hz.incorrFirstContactTimesCaAvg;


figure;

subplot(3,3,1); %
plot(xAx, rewardsCaAvg); 
title('rewards (b), punishments (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, punTimeCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,2);
plot(xAx, corrRewIndCaAvg); 
title('correct rew trials (b), incorr rew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrRewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,3);
plot(xAx, corrUnrewIndCaAvg); 
title('correct unrew trials (b), incorr unrew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,4);
plot(xAx, corrRewIndCaAvg); 
title('correct rew (b), and unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, corrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,5);
plot(xAx, incorrRewIndCaAvg); 
title('incorrect rew (b), and unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,6);
plot(xAx, incorrRewIndCaAvg); 
title('incorrect rew (b), and correct unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, corrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,7);
plot(xAx, corrRewIndCaAvg); 
title('correct rew (b), and incorrect unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrUnrewIndCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;

subplot(3,3,8);
plot(xAx, corrFirstContactTimesCaAvg); 
title('correct (b), and incorrect rew trial (r) first whisker contacts');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrFirstContactTimesCaAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'y');
hold off;
