function [eventStruc] = findStimTrigs(eventStruc, x2)


% 042414: changed method a bit because some signals small
% 021817: broke this out from dendriteBehavAnalysisNameNew as subfunction


stimTimeArr = eventStruc.correctRespStruc.stimTimeArr;
stimTypeArr = eventStruc.correctRespStruc.stimTypeArr;

stim = x2(1,:);

sf = 1000;

stim(1:100) = 0;

dStim = runmean(stim, 10);
%dStim = diff(stim2);
dStim = [0 dStim];
stdDstim = std(dStim);

stimTrigThresh =  4*stdDstim; % 0.2;  %

% find beginning of start trigger step pulse (as large pos slope)
stimTrig = LocalMinima(-dStim, sf, -stimTrigThresh);


% 013116 adjust if some events cut off (but still seem ok amplitude)
if length(stimTimeArr) ~= length(stimTrig) && max(stimSig)>3
    if abs(length(stimTimeArr)-length(stimTrig)) < 3
        [val, ind] = max(xcorr(stimTrig, stimTimeArr));
        shift = length(stimTimeArr)-ind;
        stimTrig = [zeros(shift); stimTrig];
        disp('Adjusting stimTrig because one might have gotten cut off at beginning');
    else
        stimTrig = extractStartTrigs(x2);
        
        disp('StartSig probably weird so extracting from punSig');
        
    end
end


% 051914: put this in because new above method for stimTrig detection based
% upon small signals sometimes doesn't work well for big signals when motor
% problems abort trial early

numIter = 0;
while length(stimTypeArr) ~= length(stimTrig) && numIter < 20
    if length(stimTypeArr) > length(stimTrig)
        disp('ERROR in stimTrig detection, decreasing thresh');
        stimTrigThresh =  stimTrigThresh - 0.1*stdDstim;
        stimTrig = LocalMinima(-dStim, 2*sf, -stimTrigThresh);
        numIter = numIter + 1;
    elseif length(stimTypeArr) < length(stimTrig)
        disp('ERROR in stimTrig detection, increasing thresh');
        stimTrigThresh =  stimTrigThresh + 0.1*stdDstim;
        stimTrig = LocalMinima(-dStim, 2*sf, -stimTrigThresh);
        numIter = numIter + 1;
    end
end

% if length(stimTypeArr) < length(stimTrig)
%     disp('ERROR in stimTrig, WARNING: truncating');
%     stimTrig = stimTrig(1:length(stimTypeArr));
% elseif length(stimTypeArr) > length(stimTrig)
%     xc = xcorr(diff(stimTrig), diff(stimTimeArr));
%     [val,ind] = max(xc);
%     offset = (length(xc)+1)/2-ind; % #stimInd offset bet ardStim and labv
%
%     eventStruc.correctRespStruc.stimTimeArr = stimTimeArr(offset+1:length(stimTrig)+offset-1);
%     eventStruc.correctRespStruc.stimTypeArr = stimTypeArr(offset+1:length(stimTrig)+offset-1);
% end

eventStruc.stimTrigTime = stimTrig;



