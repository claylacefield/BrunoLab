function plotEventBehavHist(cageBatchStruc, event1name, event2name)

%% USAGE: plotEventBehavHist(cageBatchStruc, event1name, event2name);
% This script bins events' eventBehavHist and plots two event types
% on which the event (like whiskContactTime1) is triggered.
% NOTE: have to have loaded a struc into cageBatchStruc var
% (can be diff from actual cageBatchStruc) 
% AND event1name is e.g. 'rewTime5EventHist'


event1 = mean(cageBatchStruc.(event1name), 2);
event2 = mean(cageBatchStruc.(event2name), 2);

binSize = 100;  % = 50;

% for i = 0:((length(event1)-(binSize+1))/binSize)
%     event1b(i+1) = sum(event1((i*binSize+1):((i+1)*binSize)));
%     event2b(i+1) = sum(event2((i*binSize+1):((i+1)*binSize)));
% end

[event1b] = histBin(event1, binSize);
[event2b] = histBin(event2, binSize);

% figure; 
% subplot(1,2,1); bar(event1b, 'c'); ylim([0 (max(event1b)+0.5)]); xlim([0 length(event1)/binSize]); 
% subplot(1,2,2); bar(event2b); ylim([0 (max(event2b)+0.5)]); xlim([0 length(event2)/binSize]);

figure;
x = -2000:binSize:6000;
x = x(2:end);
width1 = 1;
bar(x,event1b,width1,'FaceColor',[0,1,1],'EdgeColor','none');
hold on; 
width2 = 2*width1/3;
bar(x,event2b,width2,'FaceColor',[1,0,0],'EdgeColor','none');