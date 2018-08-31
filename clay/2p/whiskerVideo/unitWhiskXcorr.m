function [segCaXc] = unitWhiskXcorr(segNum, toPlot);

% Broke this script out of guiSelectGoodSegs_081217a.m for calculating unit
% whisk xcorr


useVar = 1;

load(findLatestFilename('dendriteBehavStruc'));
load(findLatestFilename('whiskDataStruc'));
load(findLatestFilename('_seg_'));

%segNum = handles.segNum;
whiskAngle = whiskDataStruc.meanAngle(1:end-1);

% frameAvgDf = dendriteBehavStruc.frameAvgDf;
segCa = segStruc.C(:,segNum);

frameTrig = dendriteBehavStruc.eventStruc.frameTrig;

if useVar==1
    whiskerData = movingvar(whiskAngle', 30);
else
    whiskerData = whiskAngle;
end


%whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies
frTimes = whiskDataStruc.frTimes;

% only take whisking var from same period as frameAvgDf
whiskerData = whiskerData(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));
frTimes = frTimes(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));

% interp frameAvgDf to whisker imaging frame times
% cax = interp1(frameTrig, frameAvgDf, frTimes);
% frCaXc = xcorr(cax, whiskerData', 1000, 'coeff');

% interp segCa to whisker imaging frame times
cax = interp1(frameTrig, segCa, frTimes);
segCaXc = xcorr(cax, whiskerData', 1000, 'coeff');

if toPlot
    figure;
    % plot(-1000:1000, (frCaXc-mean(frCaXc))/mean(frCaXc)); hold on;
    plot(-1000:1000,10*(segCaXc-mean(segCaXc))/mean(segCaXc), 'g');
    xlim([-1000 1000]);
    ylabel('xcorr');
    hold off;
end