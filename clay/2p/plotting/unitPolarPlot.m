function unitPolarPlot(segStruc, numSeg, eventName, newFig)

eventHist = squeeze(segStruc.(eventName)(:,numSeg, :));

frameRate = 4;

theta = 2*pi/33:2*pi/33:2*pi;

if newFig == 1
figure; 
else
    hold on;
end

polar(theta', eventHist);