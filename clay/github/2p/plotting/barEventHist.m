function barEventHist(eventHistBehavStruc, event1, event2, binSize)

%% USAGE: barEventHist(eventHistBehavStruc, event1, event2, binSize);


eventHist1 = eventHistBehavStruc.(event1);
eventHist2 = eventHistBehavStruc.(event2);

binSeries1 = histBin(eventHist1, binSize);
binSeries2 = histBin(eventHist2, binSize);


data = [binSeries1' binSeries2'];

BarSpecial(data, 0.8, binSize);
legend(event1, event2);
xlabel('sec after event');
ylabel('#event/trial/bin');
title([eventHistBehavStruc.eventStruc.correctRespStruc.name ' ' eventHistBehavStruc.eventType ', binSize = ' num2str(binSize) 'ms']);  