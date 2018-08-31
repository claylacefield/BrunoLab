
function plotDendBehavAnal(dendriteBehavStruc, filename, fps)

% Plotting script for data from dendriteBehavAnalysis

hz=fps;
startX = 0; % 2*hz;
stopX = 4;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);

figure;

subplot(2,3,1); %
try
plot(xAx, dendriteBehavStruc.rewStimIndCaAvg); 
catch
end
title([filename ' rewStimInd (b), punStimInd (r)']);
ylabel('dF/F'); xlabel('sec'); 
hold on;
try
plot(xAx, dendriteBehavStruc.punStimIndCaAvg, 'r'); 
catch
end
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(2,3,2); %
try
plot(xAx, dendriteBehavStruc.rewStimIndCa); 
catch
end
hold on;
title('rewStimIndCa');
ylabel('dF/F'); xlabel('sec'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(2,3,3); %
try
plot(xAx, dendriteBehavStruc.punStimIndCa);  
catch
end
hold on;
title('punStimIndCa');
ylabel('dF/F'); xlabel('sec'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;


subplot(2,3,4);
try
plot(xAx, dendriteBehavStruc.correctRewStimIndCaAvg); 
catch
end
title('correct rew trials (b), incorr rew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
try
plot(xAx, dendriteBehavStruc.incorrectRewStimIndCaAvg, 'r'); 
catch
end
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(2,3,5);
try
plot(xAx, dendriteBehavStruc.correctUnrewStimIndCaAvg); 
catch
end
title('correct unrew trials (b), incorr unrew trials (r)');
ylabel('dF/F'); xlabel('sec'); 
hold on;
try
plot(xAx, dendriteBehavStruc.incorrectUnrewStimIndCaAvg, 'r'); 
catch
end
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;


subplot(2,3,6); %
try
plot(xAx, dendriteBehavStruc.rewTime1CaAvg); 
catch
end
title([filename ' rewards (b), punishments (r)']);
ylabel('dF/F'); xlabel('sec'); 
hold on;
try
plot(xAx, dendriteBehavStruc.punTime1CaAvg, 'r'); 
catch
end
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

% subplot(3,3,4);
% plot(xAx, dendriteBehavStruc.corrRewIndCaAvg); 
% title('correct rew (b), and unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, dendriteBehavStruc.corrUnrewIndCaAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'y');
% hold off;
% 
% subplot(3,3,5);
% plot(xAx, dendriteBehavStruc.incorrRewIndCaAvg); 
% title('incorrect rew (b), and unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, dendriteBehavStruc.incorrUnrewIndCaAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'y');
% hold off;
% 
% subplot(3,3,6);
% plot(xAx, dendriteBehavStruc.incorrRewIndCaAvg); 
% title('incorrect rew (b), and correct unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, dendriteBehavStruc.corrUnrewIndCaAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'y');
% hold off;
% 
% subplot(3,3,7);
% plot(xAx, dendriteBehavStruc.corrRewIndCaAvg); 
% title('correct rew (b), and incorrect unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, dendriteBehavStruc.incorrUnrewIndCaAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'y');
% hold off;
% 
% subplot(3,3,8);
% plot(xAx, dendriteBehavStruc.corrFirstContactTimesCaAvg); 
% title('correct (b), and incorrect rew trial (r) first whisker contacts');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, dendriteBehavStruc.incorrFirstContactTimesCaAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'y');
% hold off;
