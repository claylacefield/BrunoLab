


% Plotting script for data from dendriteBehavAnalysis


figure;

subplot(2,2,1);
plot(dendriteBehavStruc.rewardsCaAvg); 
yL = get(gca, 'YLim');
line([8 8],yL, 'Color', 'y');
hold on;
plot(dendriteBehavStruc.punTimeCaAvg, 'r'); 
hold off;

subplot(2,2,2);
plot(dendriteBehavStruc.corrRewIndCaAvg); 
yL = get(gca, 'YLim');
line([8 8],yL, 'Color', 'y');
hold on;
plot(dendriteBehavStruc.incorrRewIndCaAvg, 'r'); 
hold off;

subplot(2,2,3);
plot(dendriteBehavStruc.corrUnrewIndCaAvg); 
yL = get(gca, 'YLim');
line([8 8],yL, 'Color', 'y');
hold on;
plot(dendriteBehavStruc.incorrUnrewIndCaAvg, 'r'); 
hold off;