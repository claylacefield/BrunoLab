function [hitFAeventCa, missCReventCa] = hitFAmissCRca(dendriteBehavStruc, eventType) 

%% USAGE: [hitFAeventCa, missCReventCa] = hitFAmissCRca(dendriteBehavStruc, eventType);
% script to analyze motor signals (isoLick/levLift) based upon previous
% trial response (miss+CR vs hit+FA)
% USED WITH: compileHitFAmissCRca.m
% 122314 clay

% eventType = 'isoLevLiftTime';

eventStruc = dendriteBehavStruc.eventStruc;
eventTimeCa = dendriteBehavStruc.([eventType 'Ca']);

stimTrigTime = eventStruc.stimTrigTime;
eventTime = eventStruc.(eventType);




% hit & FA ind
correctRewStimInd = eventStruc.correctRewStimInd;
incorrectUnrewStimInd = eventStruc.incorrectUnrewStimInd;
hitFAind = sort([correctRewStimInd incorrectUnrewStimInd]);

% miss & CR ind
incorrectRewStimInd = eventStruc.incorrectRewStimInd;
correctUnrewStimInd = eventStruc.correctUnrewStimInd;
missCRind = sort([incorrectRewStimInd correctUnrewStimInd]);

hitFAevent = [];
numHitFAevent = 0;
missCRevent = [];
numMissCRevent = 0;


% find nearest stimTrig before iso motor event

for eventNum = 1:length(eventTime)
    
    % find index of stimTrig just before each motor event
    prevStimInd = find(stimTrigTime < eventTime(eventNum), 1, 'last');
    
    
    % see which category the previous stim falls into
    
    if ~isempty(find(hitFAind == prevStimInd, 1))
        numHitFAevent = numHitFAevent+1;
        hitFAevent(numHitFAevent) = eventNum;
        
    elseif ~isempty(find(missCRind == prevStimInd, 1))
        numMissCRevent = numMissCRevent+1;
        missCRevent(numMissCRevent) = eventNum;
    end
    
end



hitFAeventCa = eventTimeCa(:,hitFAevent);
missCReventCa = eventTimeCa(:,missCRevent);

