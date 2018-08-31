function batchTwoEventPlotSEM(cageBatchStruc, event1, event2, hz)



event1Avg = mean(cageBatchStruc.(event1),2);
event1SEM = std(cageBatchStruc.(event1),0,2)/sqrt(size(cageBatchStruc.(event1),2));
event2Avg = mean(cageBatchStruc.(event2),2);
event2SEM = std(cageBatchStruc.(event2),0,2)/sqrt(size(cageBatchStruc.(event2),2));


event1pk = max(cageBatchStruc.(event1));
event2pk = max(cageBatchStruc.(event2));

% and some variables for plotting
startX = 0; % 2*hz;
stopX = 3;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);    % to make axis in sec (not frames)

% now plot some stuff out

figure; 
subplot(2,1,1);
plot(xAx, event1Avg); 
errorbar(xAx, event1Avg, event1SEM, 'c');
xlim([-2 6]);
% ylim([-0.05 0.2]);
title([event1 ' vs ' event2]);
ylabel('dF/F'); xlabel('sec'); 
hold on;
plot(xAx, event2Avg, 'r');
errorbar(xAx, event2Avg, event2SEM,'r');
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
legend(event1, event2);


subplot(2,1,2);
plot(event1pk, event2pk, '.');
xlim([0 0.25]);
ylim([0 0.25]);
hold on;
line([0 0.25], [0 0.25], 'Color', 'y');
xlabel([event1 ' dF/F']); ylabel([event2 ' dF/F']); 


