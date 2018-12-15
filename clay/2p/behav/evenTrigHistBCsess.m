function [evTrigHist] = evenTrigHistBCsess(eventTrigName, histEventName, toPlot)


load(findLatestFilename('dendriteBehavStruc'));
eventStruc = dendriteBehavStruc.eventStruc;

if ~isempty(strfind(eventTrigName, 'Ind'))
   stimTrig = eventStruc.stimTrigTime;
   evTimes = stimTrig(eventStruc.(eventTrigName));
else
evTimes = eventStruc.(eventTrigName);
end

sigTimes = eventStruc.(histEventName);

[evTrigHist] = eventTrigHistBC(evTimes, sigTimes); % varargin);

if toPlot
figure;
plotMeanSEMshaderr(runmean(evTrigHist,100), 'b');
end





