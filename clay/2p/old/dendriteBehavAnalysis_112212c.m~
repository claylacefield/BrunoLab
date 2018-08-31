function [ ] = dendriteBehavAnalysis()

% Master script for looking at behavior-triggered average calcium signals


% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity

[roiStruc, frameAvgDf] = dendriteProfiles();

% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

[eventStruc] = detect2pEvents();

% NOTE: need to finish correct/incorrect and estimation of punishment times
% from behavioral event TXT file


% find the times of frames and do timecourse average based upon those times


frameTrig = eventStruc.frameTrig;

corrRewInd = eventStruc.corrRewInd;
incorrRewInd = eventStruc.incorrRewInd;

corrRewStimTimes = stimTrig(corrRewInd);
incorrRewStimTimes = stimTrig(incorrRewInd);

for j=1:length(corrRewStimTimes)
    zeroFrame(j) = find(frameTrig >= corrRewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - 4;
endFrame = zeroFrame + 10;

for k = 1:length(endFrame)

corrRewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

plot(corrRewCa(:,k));

end

corrRewCaAvg = mean(corrRewCa, 2);

%figure; plot(

for j=1:length(incorrRewStimTimes)
    zeroFrame(j) = find(frameTrig >= incorrRewStimTimes(j), 1, 'first');
end

beginFrame = zeroFrame - 4;
endFrame = zeroFrame + 10;

for k = 1:length(endFrame)

incorrRewCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));

plot(incorrRewCa(:,k), 'r');

end

incorrRewCaAvg = mean(incorrRewCa, 2);
