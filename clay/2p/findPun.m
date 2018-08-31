function [eventStruc] = findPun(eventStruc, punSig)

punArr = eventStruc.correctRespStruc.punArr;

dPun = [0 diff(punSig)];

% detect punishment signals
punTime = LocalMinima(-dPun, 200, -1);

if length(punArr)~=length(punTime)
    disp('wrong number punishment events');
    disp(['length(punArr) = ' num2str(length(punArr))]);
    disp(['length(punTime) = ' num2str(length(punTime))]);
    
    if length(punArr) < length(punTime)
        punTime = punTime(1:length(punArr));
        disp('truncating punTime to punArr length');
    else    % if punArr>punTime
        punArrArdT = correctRespStruc.punArrArdT;
        xc = xcorr(diff(punTime), diff(punArrArdT));
        [val,ind] = max(xc);
        offset = (length(xc)+1)/2-ind; % #stimInd offset bet ardStim and labv
        punArr = punArr(offset+1:length(punTime)+offset);
        eventStruc.correctRespStruc.punArr = punArr;
        
    end
    
end

eventStruc.punTime = punTime;

% find pun types
punInd1 = find(punArr == 1);
punInd2 = find(punArr == 2);
punInd3 = find(punArr == 3);
punInd4 = find(punArr == 4);
punTime1 = punTime(punInd1);
eventStruc.punTime1 = punTime1; % normal pun
eventStruc.punTime2 = punTime(punInd2);     % rewPun switch
eventStruc.punTime3 = punTime(punInd3);     % pun tone skip
eventStruc.punTime4 = punTime(punInd4);     % rewPun switch tone skip

eventStruc.punArr = eventStruc.correctRespStruc.punArr;