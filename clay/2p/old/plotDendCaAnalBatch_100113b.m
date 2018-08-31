function plotDendCaAnalBatch(fps)

% Plotting script for data from dendriteBehavAnalysis


% INPUT fps of struc in workspace to analyze
%hz = 4;
hz=fps;

% load desired struc from workspace (dep on fps)
batchDendStruc = eval(['batchDendStruc' num2str(hz) 'hz']); 

% load in values to plot (NOTE: new var renamed to match old)
rewardsCaAvg = batchDendStruc.rewTime1CaAvg;
punTimeCaAvg = batchDendStruc.punTime1CaAvg;
corrRewIndCaAvg = batchDendStruc.correctRewStimIndCaAvg;
incorrRewIndCaAvg = batchDendStruc.incorrectRewStimIndCaAvg;
corrUnrewIndCaAvg = batchDendStruc.correctUnrewStimIndCaAvg;
incorrUnrewIndCaAvg = batchDendStruc.incorrectUnrewStimIndCaAvg;
corrFirstContactTimesCaAvg = batchDendStruc.firstContactTimes1CaAvg;
incorrFirstContactTimesCaAvg = batchDendStruc.firstContactTimes2CaAvg;

rewardsCaAvgAvg = mean(rewardsCaAvg,2);
punTimeCaAvgAvg = mean(punTimeCaAvg,2);
corrRewIndCaAvgAvg = mean(corrRewIndCaAvg,2);
incorrRewIndCaAvgAvg = mean(incorrRewIndCaAvg,2);
corrUnrewIndCaAvgAvg = mean(corrUnrewIndCaAvg,2);
incorrUnrewIndCaAvgAvg = mean(incorrUnrewIndCaAvg,2);
corrFirstContactTimesCaAvgAvg = mean(corrFirstContactTimesCaAvg,2);
incorrFirstContactTimesCaAvgAvg = mean(incorrFirstContactTimesCaAvg,2);

% and some variables for plotting
startX = 0; % 2*hz;
stopX = 4;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);    % to make axis in sec (not frames)


%% NOW PLOT EVERYTHING

figure;

subplot(3,3,1); %
plot(xAx, rewardsCaAvgAvg); 
title('rewards (b), punishments (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, punTimeCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,2);
plot(xAx, corrRewIndCaAvgAvg); 
title('correct rew trials (b), incorr rew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrRewIndCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,3);
plot(xAx, corrUnrewIndCaAvgAvg); 
title('correct unrew trials (b), incorr unrew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrUnrewIndCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,4);
plot(xAx, corrRewIndCaAvgAvg); 
title('correct rew (b), and unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, corrUnrewIndCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,5);
plot(xAx, incorrRewIndCaAvgAvg); 
title('incorrect rew (b), and unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrUnrewIndCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,6);
plot(xAx, incorrRewIndCaAvgAvg); 
title('incorrect rew (b), and correct unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, corrUnrewIndCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,7);
plot(xAx, corrRewIndCaAvgAvg); 
title('correct rew (b), and incorrect unrew (r) trials');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrUnrewIndCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(3,3,8);
plot(xAx, corrFirstContactTimesCaAvgAvg); 
title('correct (b), and incorrect rew trial (r) first whisker contacts');
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, incorrFirstContactTimesCaAvgAvg, 'r'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off; 

subplot(3,3,9);
plot(xAx, corrRewIndCaAvg); 
title('rewStimInd (each day)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
