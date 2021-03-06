function [evTrigHistCell, eventNames, path] = eventTrigLickWhiskSess(toPlot)

% Clay Dec. 2018
% calculate licking and whisking for a session.

path = pwd;

eventTrigName{1} = 'correctRewStimInd';
eventTrigName{2} = 'rewTime1';
eventTrigName{3} = 'rewDelay1Time';

histEventName{1} = 'lickTime';
histEventName{2} = 'whiskContactTime1';
histEventName{3} = 'rewTime1';

eventNames = {eventTrigName, histEventName};

if toPlot
figure('Position', [50, 50, 1200, 400]);
end 

for i=1:length(eventTrigName)
    for j=1:length(histEventName)
        try
        [evTrigHistCell{i,j}] = evenTrigHistBCsess(eventTrigName{i}, histEventName{j}, 0);
        catch
            disp(['Problem with event:' eventTrigName{i} ', ' histEventName{j}]);
            [evTrigHistCell{i,j}] = NaN(8000,1);
        end
    end
    
    if toPlot
        subplot(1,3,i);
        plotMeanSEMshaderr(runmean(evTrigHistCell{i,1},100), 'g');
        hold on;
        plotMeanSEMshaderr(runmean(evTrigHistCell{i,2},100), 'r');
        plotMeanSEMshaderr(runmean(evTrigHistCell{i,3},100), 'b');
        title([eventTrigName{i} ',lk=g,wh=r,rw=b']);
    end
end