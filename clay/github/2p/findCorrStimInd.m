function [eventStruc] = findCorrStimInd(eventStruc)

correctRespStruc = eventStruc.correctRespStruc;

stimType = correctRespStruc.stimTypeArr;
corrRespArr = correctRespStruc.corrRespArr;
incorrLevPressLatency = correctRespStruc.incorrLevPressLatency;

eventStruc.stimType = stimType;

% find indices of diff trial types
rewStimStimInd = find(stimType == 1);
unrewStimStimInd = find(stimType == 2);

%% NOTE: these are for all trials, including experimenter triggered
% correct resp
typeXresp = stimType.*corrRespArr;  % creates array with stim type if correct and 0 if incorrect
corrRewInd = find(typeXresp == 1); % then find the indices of correct rewarded trials
corrUnrewInd = find(typeXresp == 2);    % and incorrect

% incorr resp
typeXincorr = stimType-typeXresp;   % and reverse for incorrect responses
incorrRewInd = find(typeXincorr == 1); 
incorrUnrewInd = find(typeXincorr == 2);

%%

eventStruc.rewStimStimInd = rewStimStimInd;
eventStruc.unrewStimStimInd = unrewStimStimInd;
% eventStruc.corrRewInd = corrRewInd;
% eventStruc.corrUnrewInd = corrUnrewInd;
% eventStruc.incorrRewInd = incorrRewInd;
% eventStruc.incorrUnrewInd = incorrUnrewInd;

eventStruc.correctStimInd = correctRespStruc.correctStimInd;
eventStruc.incorrectStimInd = correctRespStruc.incorrectStimInd;

eventStruc.rewStimInd = correctRespStruc.rewStimInd;
eventStruc.punStimInd = correctRespStruc.punStimInd;
% eventStruc.unrewStimInd = correctRespStruc.unrewStimInd;
eventStruc.correctRewStimInd = correctRespStruc.correctRewStimInd;
eventStruc.correctUnrewStimInd = correctRespStruc.correctUnrewStimInd;
eventStruc.incorrectRewStimInd = correctRespStruc.incorrectRewStimInd;
eventStruc.incorrectUnrewStimInd = correctRespStruc.incorrectUnrewStimInd;

eventStruc.rewArr = correctRespStruc.rewArr;
eventStruc.punArr = correctRespStruc.punArr;