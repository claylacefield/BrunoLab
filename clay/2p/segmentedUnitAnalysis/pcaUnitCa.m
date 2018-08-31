function [pcaUnitStruc] = pcaUnitCa(segStruc, goodSeg, toNorm, toPlot)

%080617

rc = segStruc.rewStimStimIndCa;
rs = segStruc.rewStimStimIndRoiHist;
uc = segStruc.unrewStimStimIndCa;
us = segStruc.unrewStimStimIndRoiHist;


mrc = squeeze(mean(rc,3));
mrcg = mrc(:,goodSeg);

if toNorm
for i = 1:length(goodSeg)
   mrcgn(:,i) = (mrcg(:,i)-mean(mrcg(:,i)))/var(mrcg(:,i)); 
end
else
    mrcgn = mrcg;
end

[coeff, score, lat, tsq, explained, mu] = pca(mrcgn');



pcaUnitStruc.coeff = coeff;
pcaUnitStruc.score = score;
pcaUnitStruc.latent = lat;
pcaUnitStruc.tsquared =  tsq;
pcaUnitStruc.explained =  explained;
pcaUnitStruc.mu = mu;


if toPlot
figure; 
plot(-2:0.25:6, coeff(:,1:8));
end