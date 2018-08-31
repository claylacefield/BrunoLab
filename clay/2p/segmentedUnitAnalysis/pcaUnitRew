function [coeff, coeff2] = pcaUnitRew(segStruc, goodSeg)

rewCa = segStruc.rewStimStimIndCa;
avRewCa = mean(rewCa, 3);

for seg = 1:length(goodSeg)
    ca = avRewCa(:,goodSeg(seg));
    ca2 = (ca-mean(ca))/std(ca);
    unitCa(:,seg) = ca2;
    dCa(:,seg) = [0; diff(ca2)];
end

coeff = pca(unitCa');
numPcs = 5;
colors = jet(numPcs);
figure; hold on;
for pc = 1:numPcs
    plot(coeff(:,pc), 'Color', colors(pc,:));
    
end

coeff2 = pca(dCa');

figure; hold on;
for pc = 1:numPcs
    plot(coeff2(:,pc), 'Color', colors(pc,:));
    
end
