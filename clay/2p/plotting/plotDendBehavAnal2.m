function plotDendBehavAnal2(dendriteBehavStruc, fps)

% Plotting script for data from dendriteBehavAnalysis
try
filename = dendriteBehavStruc.filename;
catch
    try
    filename = dendriteBehavStruc.eventStruc.filename;
    catch
        filename = pwd;
    end
end
    

hz=fps;
startX = 0; % 2*hz;
stopX = 4;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);

figure;

subplot(2,3,1); %

fields = {'rewStimStimIndCa' 'unrewStimStimIndCa'};

try
%plot(xAx, dendriteBehavStruc.rewStimIndCaAvg); 
plotAFewFieldsSEMsubplot(dendriteBehavStruc, fields,0);
catch
end
% title([filename ' rewStimInd (b), punStimInd (r)']);
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% try
% plot(xAx, dendriteBehavStruc.punStimIndCaAvg, 'r'); 
% catch
% end
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;

title(filename);

subplot(2,3,2); %

fields = {'correctRewStimIndCa' 'incorrectRewStimIndCa'};

try
plot(xAx, dendriteBehavStruc.(fields{2}), 'r'); 
catch
end
hold on;
try
plot(xAx, dendriteBehavStruc.(fields{1}), 'b'); 
catch
end

title([fields{1} ' vs. ' fields{2}]);
ylabel('dF/F'); xlabel('sec'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
hold off;

subplot(2,3,3); %

fields = {'correctUnrewStimIndCa' 'incorrectUnrewStimIndCa'};

try
plot(xAx, dendriteBehavStruc.(fields{2})*0.5, 'r'); 
catch
end
hold on;
try
plot(xAx, dendriteBehavStruc.(fields{1})*0.5, 'b'); 
catch
end

% title([fields{1} ' vs. ' fields{2}]);
% ylabel('dF/F'); xlabel('sec'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');

% try
% %plot(xAx, dendriteBehavStruc.rewStimIndCaAvg); 
% plotAFewFieldsSEMsubplot(dendriteBehavStruc, fields,0);
% catch
% end

title([fields{1} ' vs. ' fields{2}]);
ylabel('dF/F'); xlabel('sec'); 
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');

hold off;

subplot(2,3,4);

fields = {'rewTime1Ca' 'punTime1Ca'};

try
%plot(xAx, dendriteBehavStruc.rewStimIndCaAvg); 
plotAFewFieldsSEMsubplot(dendriteBehavStruc, fields,0);
catch
end

subplot(2,3,5);

fields = {'correctRewStimIndCa' 'incorrectRewStimIndCa'};

try
%plot(xAx, dendriteBehavStruc.rewStimIndCaAvg); 
plotAFewFieldsSEMsubplot(dendriteBehavStruc, fields,0);
catch
end

subplot(2,3,6); %

fields = {'correctUnrewStimIndCa' 'incorrectUnrewStimIndCa'};

try
%plot(xAx, dendriteBehavStruc.rewStimIndCaAvg); 
plotAFewFieldsSEMsubplot(dendriteBehavStruc, fields,0);
catch
end

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
