function [actionBinCell] = eventBehavMouseSumm(dendriteBehavStruc, eventName, toPlot)

%% USAGE: [actionTrialArr] = eventBehavMouseSumm(dendriteBehavStruc, eventName, actionName);
% eventName = 'correctRewStimInd';
% actionName = 'whisk', or 'lick'

% Script to find times of key events,
% take sum of all events over all the trials, 
% bin them, then divide by # trials

% eventName = 'correctRewStimInd';
% 
% dendriteBehavStruc = mouseSummCell{7,10};
eventStruc = dendriteBehavStruc.eventStruc;

actionCell{1} = eventStruc.whiskContactTime1;
actionCell{2} = eventStruc.lickTime;

eventInds = eventStruc.(eventName);
stimTrigTime = eventStruc.stimTrigTime;

frameTrig = eventStruc.frameTrig;
maxCaTime = max(frameTrig);
%caFps = 1000/mean(diff(frameTrig)); % about 3.4
caFps = 3.4;

% actionSig = zeros(maxCaTime,1);
% actionSig(actionTimes) = 1;

preEvent = round(8/caFps*1000);
postEvent = round(24/caFps*1000);

%tic;

for k = 1:2
    actionTimes = actionCell{k};
    for i = 1:length(eventInds)
        binTrial = zeros(preEvent+postEvent, 1);
        event = stimTrigTime(eventInds(i));
        
        actionTimeTrial = actionTimes(actionTimes>event-preEvent & actionTimes<event+postEvent);
        binTrial(actionTimeTrial-(event-preEvent)) = 1;
        actionTrialArr(:,i) = binTrial;
        
    end
    
    actionArr = mean(actionTrialArr,2);
    
    binSize = 280; % 150;
    numBins = floor(size(actionArr,1)/binSize);
    actionBin = [];
    for j=1:numBins
        actionBin(j) = sum(actionArr((j-1)*binSize+1:j*binSize));
    end
    
    actionBinCell{k} = actionBin';
    
end

%toc;

if toPlot
    figure;
    subplot(2,1,1);
    plotMeanSEM(dendriteBehavStruc.([eventName 'Ca']), 'b');
    title([dendriteBehavStruc.filename ' ' eventName]);
    subplot(2,1,2);
    bar(actionBinCell{1},'r'); hold on; bar(actionBinCell{2},'b');
    legend('contacts', 'licks');
    xlim([0 size(actionBinCell{1},1)]);
    title('whisk contacts');
end