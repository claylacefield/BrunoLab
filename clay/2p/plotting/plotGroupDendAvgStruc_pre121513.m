function [outStruc] = plotGroupDendAvgStruc(groupDendAvgStruc, fps)


% a script to meta-analyze behavioral calcium signals

% [filename, pathname] = uigetfile('*.mat', 'Select a batchDendStruc to read');
% 
% cd(pathname);
% load(filename);
% 
% hz = str2num(filename((strfind(filename, 'hz')-1)));

hz=fps;

% load desired struc from workspace (dep on fps)
batchDendStruc = groupDendAvgStruc; % eval(['batchDendStruc' num2str(hz) 'hz']); 

fieldNames = fieldnames(batchDendStruc);

 for field = 1:length(fieldNames)
     
     if strfind(fieldNames{field}, 'Avg')
     
     event = batchDendStruc.([fieldNames{field}]);
     
     for day = 1:size(event,2)
         dayAvg = [event(:,day)];
         %peakInd(day) = LocalMinima(-dayAvg, 8*hz, -0.001);
         [C,I] = max(dayAvg(8:16));
         peaks(day,1) = I+7; % index of peak
         baseline = mean(dayAvg(1:hz),1);
         C = C-baseline;
         peaks(day,2) = C;
     end
     
     outStruc.(fieldNames{field}) = peaks;
     
     clear peaks;
     
     end
     
 end

 
rewTime1Avg = mean(batchDendStruc.rewTime1CaAvg,2);
rewTime5Avg = mean(batchDendStruc.rewTime5CaAvg,2);


[C,I] = max(rewTime1Avg(8:16));
baseline = mean(rewTime1Avg(1:hz),1);
C = C-baseline;
outStruc.rewPeak = C;

[C,I] = max(rewTime5Avg(8:16));
baseline = mean(rewTime5Avg(1:hz),1);
C = C-baseline;
outStruc.firstWhiskPeak = C;
 
 
 
 % and some variables for plotting
startX = 0; % 2*hz;
stopX = 4;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);    % to make axis in sec (not frames)


figure; 

subplot(2,2,1); 
plot(outStruc.rewTime1CaAvg(:,1), outStruc.rewTime1CaAvg(:,2), '.');
hold on;
plot(outStruc.rewTime5CaAvg(:,1), outStruc.rewTime5CaAvg(:,2), 'r.');

subplot(2,2,3); 
plot(outStruc.rewTime1CaAvg(:,2), '.');
hold on;
plot(outStruc.rewTime5CaAvg(:,2), 'r.');

subplot(2,2,2);
plot(xAx, rewTime1Avg);
hold on; 
plot(xAx, rewTime5Avg, 'r');
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');

subplot(2,2,4);
% figure;
plot(outStruc.rewTime1CaAvg(:,2), outStruc.rewTime5CaAvg(:,2), '.');
% xL = get(gca, 'XLim');
% yL = get(gca, 'YLim');
hold on;
plot([0 0.35],[0 0.35], 'y');
xlabel('rewTime'); ylabel('firstContactTime');

% figure; 
% plot(outStruc.rewTime1CaAvg(:,1), '.'); 
% hold on;
% plot(outStruc.rewStimIndCaAvg(:,1),'r.');
