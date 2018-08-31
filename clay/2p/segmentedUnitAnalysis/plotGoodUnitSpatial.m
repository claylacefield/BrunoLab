function plotGoodUnitSpatial(segStruc, goodSeg)


% This script plots the spatial profiles of segmented units (goodSegs)
% based upon their peak times


rewCa = segStruc.rewStimStimIndCaAvg(:,goodSeg);


% find the peak of avgCa for each unit
[pkVal, pkInd] = max(rewCa);


unitSpat = segStruc.A(goodSeg, :);

% unitPkInd1 = find(pkInd == 11 | pkInd == 12); 
% unitPkInd2 = find(pkInd == 13 | pkInd == 14); 
% unitPkInd3 = find(pkInd >= 15 & pkInd < 20); 
% unitPkInd4 = find(pkInd >= 20 & pkInd < 25); 

%allUnitSpat = mean(unitSpat,1);

d1 = segStruc.d1;
d2 = segStruc.d2;

%allUnitSpat = reshape(allUnitSpat, d1, d2);

unitSpat1 = reshape(mean(unitSpat,1), d1, d2);
% unitSpat2 = reshape(mean(unitSpat(unitPkInd2,:),1), d1, d2);
% unitSpat3 = reshape(mean(unitSpat(unitPkInd3,:),1), d1, d2);
% unitSpat4 = reshape(mean(unitSpat(unitPkInd4,:),1), d1, d2);

% plotting
figure; 
% subplot(1,4,1);
imagesc(unitSpat1);
% subplot(1,4,2);
% imagesc(unitSpat2);
% subplot(1,4,3);
% imagesc(unitSpat3);
% subplot(1,4,4);
% imagesc(unitSpat4);