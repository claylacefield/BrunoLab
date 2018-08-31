function unitPcaLinreg(toNorm)

%%
% Wrapper script for some unit analysis
% clay Aug 2017

segFilename = findLatestFilename('_seg_');
load(segFilename);
goodSegFilename = findLatestFilename('_goodSeg_');
load(goodSegFilename);


figure;


%%
toPlot = 0; %toNorm = 1;
sortEvent = 'rewStimStimIndCa'; %'correctRewStimIndCa';%
plotEvent = sortEvent;
[unitSort, origInd] = sortUnitsByTime(segStruc, goodSeg, sortEvent, plotEvent, toNorm, toPlot);

subplot(2,3,1);
colormap(jet);
imagesc(unitSort);
title(segStruc.filename);



%% unit xcorr
toPlot = 0;
[corrCoeff] = xcorrUnitTemp(segStruc, goodSeg(origInd), toPlot);

c2 = max(corrCoeff, [], 3);

for i = 1:size(c2,2)
    c2(i,i) = min(c2(:)); % 0;
end

subplot(2,3,2);
imagesc(c2);


%% PCA of unit rewStimStimIndCa
%toNorm = 1; 
toPlot = 0;
[pcaUnitStruc] = pcaUnitCa(segStruc, goodSeg, toNorm, toPlot);
exp = pcaUnitStruc.explained;
coeff = pcaUnitStruc.coeff;
hiExp = find(exp>=5);

subplot(2,3,4);
goodCoeff = coeff(:,hiExp);
colors = jet(length(hiExp));
%plot(-2:0.25:6, goodCoeff);

hold on;
for i = 1:size(goodCoeff,2)
    plot(-2:0.25:6, goodCoeff(:,i), 'Color', colors(i,:));
end
hold off;
xlim([-2 6]);
ylim([min(goodCoeff(:)) max(goodCoeff(:))]);
legend(num2str(exp(hiExp)));


%% Linear regression

% C = segStruc.C(:,goodSeg);
% 
% [linRegStruc] = RegressClayCalciumSeg(ca, frameShift);

%% noise correlation


%% whisking xcorr


try
    
    disp('Calc unit whisk xcorr'); tic;
whiskDataStrucName = findLatestFilename('whiskDataStruc');
load(whiskDataStrucName);

load(findLatestFilename('dendriteBehavStruc'));

C = segStruc.C;
goodUnitCa = C(:,goodSeg(origInd));


frameTrig = dendriteBehavStruc.eventStruc.frameTrig;
%frameAvgDf = dendriteBehavStruc.frameAvgDf;
tMs = frameTrig(1):frameTrig(end);  % time in ms of 2p imaging

whiskerData = -whiskDataStruc.meanAngle(1:end-1); % = whiskDataStruc.medianAngle;
% NOTE: inverting this because protractions are negative-going from these
% PS3eye movies
frTimes = whiskDataStruc.frTimes;

% only take whisking var from same period as frameAvgDf
whiskerData = whiskerData(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));
frTimes = frTimes(find(frTimes>=frameTrig(1) & frTimes <= frameTrig(end)));

% now interp whiskerData to ms
whiskerData = interp1(frTimes, whiskerData, tMs);
whiskerData(isnan(whiskerData)) = nanmean(whiskerData);  % think this is to eliminate possible NaNs and replace with mean of signal
wd3 = (whiskerData - mean(whiskerData))/std(whiskerData);


for i = 1:length(goodSeg)
    
    ca = goodUnitCa(:,i);
    
% interp frameAvgDf to ms
ca2 = interp1(frameTrig, ca, tMs);
ca2(isnan(ca2)) = nanmean(ca2);
ca3 = (ca2-mean(ca2))/std(ca2);

xc = xcorr(ca3, wd3', 3000, 'coeff');
unitWhiskXcorr(:, i) = xc';

end

subplot(2,3,6);
plotTracesByColor(unitWhiskXcorr, 0);
xlim([0 6001]);

toc;


%% 

subplot(2,3,3);
uwx = unitWhiskXcorr';
imagesc(max(uwx(:,2000:4000),[],2));

 catch
 end