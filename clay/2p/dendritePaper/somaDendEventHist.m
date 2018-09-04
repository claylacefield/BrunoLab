function [somaDendCaStruc] = somaDendEventHist(mouseSummCell, summStrucFields, progNameTag, eventName, toAvgTrials, toPlot)

tic;
%somaDendCaStruc = [];

[somaVals, dendVals, somaCellInds, dendCellInds] = avgFieldMouseSummSomaDend(mouseSummCell, summStrucFields, progNameTag, eventName, toAvgTrials, 0);
somaDendCaStruc.somaVals = somaVals;
somaDendCaStruc.dendVals = dendVals;

somaWhiskContacts = [];

for i = 1:length(somaCellInds)
    dendriteBehavStruc = mouseSummCell{somaCellInds(i), 10};
    [actionBinCell] = eventBehavMouseSumm(dendriteBehavStruc, eventName, 0);
    somaWhiskContacts = [somaWhiskContacts actionBinCell{1}];
end
somaDendCaStruc.somaWhiskContacts = somaWhiskContacts;

dendWhiskContacts = [];

for i = 1:length(dendCellInds)
    dendriteBehavStruc = mouseSummCell{dendCellInds(i), 10};
    [actionBinCell] = eventBehavMouseSumm(dendriteBehavStruc, eventName, 0);
    dendWhiskContacts = [dendWhiskContacts actionBinCell{1}];
end
somaDendCaStruc.dendWhiskContacts = dendWhiskContacts;

if toPlot
figure;
subplot(2,1,1);
try
plotMeanSEM(somaVals, 'r');
catch
    disp('No somaVals');
end
hold on; 
try
plotMeanSEM(dendVals, 'b');
catch
    disp('No dendVals');
end
legend('soma', 'dend');
title([mouseSummCell{1,1} ' ' progNameTag ' ' eventName ' soma vs. dend (matched) on ' date]);
xlabel('secs');
ylabel('dF/F');

subplot(2,1,2);
try
plotMeanSEM(somaWhiskContacts, 'r');
catch
    disp('No somaWhiskContacts');
end
hold on; 
try
plotMeanSEM(dendWhiskContacts, 'b');
catch
    disp('No dendWhiskContacts');
end

legend('soma', 'dend');
    %xlim([0 size(somaWhiskContacts,1)]);
    title('whisk contacts');

end
toc;
