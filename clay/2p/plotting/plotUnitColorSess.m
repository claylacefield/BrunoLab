function plotUnitColorSess()


load(findLatestFilename('_seg_'));
load(findLatestFilename('_goodSeg_'));
try
load(findLatestFilename('_somaDendTif'));
catch
    disp('No somaDendTif');
end

load(findLatestFilename('_dendriteBehavStruc_'));

eventName = 'correctRewStimIndCa';

evCaUnits = segStruc.(eventName)(:,goodSeg,:);

avgCa = mean(evCaUnits,3);

figure('pos', [50, 50, 400, 800]); 

spHand1 = subplot(3,1,1);
plotUnitsByTime(segStruc, goodSeg);
try
title([segStruc.filename ' ' somaDend]);
catch
end

% pos1 = get(spHand1, 'Position');
% newPos1 = pos1 + [0 -0.3 0 0.3];
% set(spHand1, 'Position', newPos1);

spHand2 = subplot(3,1,2);
plot(mean(avgCa,2));
xlim([1 33]);
% pos2 = get(spHand2, 'Position');
% set(spHand2, 'Position', (pos2 + [0, -0.3, 0, 0.1]));

spHand3 = subplot(3,1,3);
plot(mean(dendriteBehavStruc.(eventName),2));
xlim([1 33]);