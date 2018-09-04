
somaDend = 'd'; 
prog = 'Delay';
field = 'correctRewStimInd';


[compilVals] = avgFieldMouseSumm(mouseSummCell, summStrucFields, somaDend, prog, field, 1); 

figure; 

plotMeanSEM(compilVals, 'b');
title([mouseSummCell{1} ' ' somaDend ' ' prog ' ' field ' ' date]);