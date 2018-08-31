function [correctRespStruc] = fixCorrRespStimInd(correctRespStruc, stimTrig)

stimTimeArr = correctRespStruc.stimTimeArr;

% calculate stimTrig offset
% usu. trial or so at beginning that weren't captured in labview
xc = xcorr(diff(stimTrig), diff(stimTimeArr));
[val,ind] = max(xc);
offset = (length(xc)+1)/2-ind; % #stimInd offset bet ardStim and labv

correctRespStruc.stimTimeArr = correctRespStruc.stimTimeArr(offset+1:length(stimTrig)+offset);
correctRespStruc.stimTypeArr = correctRespStruc.stimTypeArr(offset+1:length(stimTrig)+offset);
correctRespStruc.corrRespArr = correctRespStruc.corrRespArr(offset+1:length(stimTrig)+offset);

fieldCell = fieldnames(correctRespStruc);

for i = 1:length(fieldCell)
    fieldName = fieldCell{i};
    fieldVals = correctRespStruc.(fieldName);
    
    if strfind(fieldName, 'StimInd')
        
        fieldBase = fieldName(1:strfind(fieldName, 'StimInd')-1);
        
        % cut off stim ind <= offset and > length(stimTrig)+offset
        preTrim = offset; % both non-inclusive
        postTrim = length(stimTrig)+offset+1;
        try
            stimInd = fieldVals;
            goodInds = find(stimInd>preTrim & stimInd < postTrim);
            correctRespStruc.(fieldName) = stimInd(goodInds)-offset;
            lat = correctRespStruc.([fieldBase 'Latency']);
            correctRespStruc.([fieldBase 'Latency']) = lat(goodInds);
        catch
        end
        
%     elseif strcmp(fieldName, 'rewArr')
%         correctRewStimInd = correctRespStruc.correctRewStimInd;
%     elseif strcmp(fieldName, 'punArr')
%         incorrectUnrewStimInd = correctRespStruc.incorrectUnrewStimInd;
    end
end

% don't forget rewArr and punArr
