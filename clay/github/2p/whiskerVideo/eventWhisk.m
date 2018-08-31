function [evWhiskArr] = eventWhisk(dendriteBehavStruc, whiskDataStruc, eventName)

% Clay 091616: script to extract whisking for a given event type (for
% comparison with calcium)
% NOTE: this method finds the zero frame times for an event, finds the
% whisking frame time closest to this, then the frames closest to the
% beginning and ending of the calcium epoch. This is agnostic to calcium
% imaging framerate, possible unlike previous methods.

ma = whiskDataStruc.meanAngle(1:end-1);
ma=ma';
%figure; plot(ma);
ma2 = -(ma-mean(ma))/std(ma);
whFrTimes = whiskDataStruc.frTimes;

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
evFrInds = dendriteBehavStruc.(eventName);
evBegInds = evFrInds-8;
evEndInds = evFrInds+24;
evBegTimes = frameTrig(evBegInds);
evEndTimes = frameTrig(evEndInds);


for evNum = 1:length(evFrInds)
    %evFrTimes(evNum);
    evBegWhInd = find(whFrTimes >= evBegTimes(evNum), 1);
    evEndWhInd = find(whFrTimes >= evEndTimes(evNum), 1);
    evWhisk = ma2(evBegWhInd:evEndWhInd);
    evWhisk2 = interp1(whFrTimes(evBegWhInd:evEndWhInd),evWhisk,linspace(whFrTimes(evBegWhInd), whFrTimes(evEndWhInd),4000)');
    evWhiskArr(:,evNum) = evWhisk2;
end

