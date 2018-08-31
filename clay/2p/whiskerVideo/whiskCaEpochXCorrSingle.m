function [r] = whiskCaEpochXCorrSingle(ca2, whiskerData, tMs, epBegInd, epEndInd)




for trial = 1:length(epBegInd)
    try
    itiCa = ca2(tMs>=epBegInd(trial) & tMs<=epEndInd(trial));
    itiWhisk = whiskerData(tMs>=epBegInd(trial) & tMs<=epEndInd(trial));
    r(trial, :) = xcorr(itiCa, itiWhisk, 300, 'coeff');
    catch
        r(trial, :) = NaN(1,601);
    end
end






