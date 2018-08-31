function [outStruc] = plotGroupDendAvgStruc(groupDendAvgStruc, numDays, event1, event2, fps)


% a script to meta-analyze behavioral calcium signals
% NOTE: this outputs peaks of event-triggered calcium signals
% from an animal over time, and plotted against each other

% I think this takes a batchStruc (usually from a single animal)
% and plots out calcium peaks from some predetermined behavioral events

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

for field = 1:length(fieldNames)    % go through all the fields
    
    if strfind(fieldNames{field}, 'Avg')
        
        % load in the event-triggered Ca signal
        event = batchDendStruc.([fieldNames{field}]);
        
        % and for each day, find the Ca peak for this event
        for day = 1:size(event,2)
            dayAvg = event(:,day);
            %peakInd(day) = LocalMinima(-dayAvg, 8*hz, -0.001);
            [C,I] = max(dayAvg(8:16));
            peaks(day,1) = I+7; % index of peak
            baseline = mean(dayAvg(1:hz),1);
            C = C-baseline;     % and peak amplitude
            peaks(day,2) = C;
            
            clear dayAvg;
        end
        
        % this outputs a 2D array of peak indices and amplitudes
        outStruc.(fieldNames{field}) = peaks;
        
        clear peaks;
        clear event;
        
    end
    
    
end




% choose a couple events to compare
event1Avg = batchDendStruc.(event1);
event2Avg = batchDendStruc.(event2);

% and take the mean over a certain number of days
event1Avg = mean(event1Avg(:,1:numDays),2);
event2Avg = mean(event2Avg(:,1:numDays),2);

eventFieldCell1 = strfind(fieldNames, event1);
eventFieldInd1 = find(not(cellfun('isempty', eventFieldCell1)));
eventFieldCell2 = strfind(fieldNames, event2);
eventFieldInd2 = find(not(cellfun('isempty', eventFieldCell2)));

% find Ca peaks in those events (in a certain time window)
[C,I] = max(event1Avg(8:16));
baseline = mean(event1Avg(1:hz),1);   % find a pre-event baseline to subtract
C = C-baseline;
outStruc.rewPeak = C;

[C,I] = max(event2Avg(8:16));
baseline = mean(event2Avg(1:hz),1);
C = C-baseline;
outStruc.firstWhiskPeak = C;



% and some variables for plotting
startX = 0; % 2*hz;
stopX = 4;
step = 1/hz;
xAx = linspace(-2,6,8*hz+1);    % to make axis in sec (not frames)


figure;

% plot the time(index) of the Ca peaks
subplot(2,2,1);
plot(outStruc.(event1)(:,1), outStruc.(event1)(:,2), '.');
hold on;
plot(outStruc.(event2)(:,1), outStruc.(event2)(:,2), 'r.');
xlabel('latency'); ylabel('peak dF/F');

subplot(2,2,3);
plot(outStruc.(event1)(:,2), '.');
hold on;
plot(outStruc.(event2)(:,2), 'r.');
xlabel('days'); ylabel('peak dF/F');

subplot(2,2,2);
plot(xAx, event1Avg);
hold on;
plot(xAx, event2Avg, 'r');
yL = get(gca, 'YLim');
line([startX startX],yL, 'Color', 'g');
line([stopX stopX],yL, 'Color', 'r');
xlabel('sec'); ylabel('dF/F');

try
    subplot(2,2,4);
    % figure;
    plot(outStruc.(event1)(:,2), outStruc.(event2)(:,2), '.');
    % xL = get(gca, 'XLim');
    % yL = get(gca, 'YLim');
    hold on;
    plot([0 0.35],[0 0.35], 'y');
    xlabel(event1); ylabel(event2);
catch
end

% figure;
% plot(outStruc.event1CaAvg(:,1), '.');
% hold on;
% plot(outStruc.rewStimIndCaAvg(:,1),'r.');
