function [pcaUnitEpochStruc] = pcaUnitEpochs(unitEventRateCompilStruc)



[coeff,score,latent, tsquared, explained, mu] = pca([unitEventRateCompilStruc.unitRewEpochMat; unitEventRateCompilStruc.unitUnrewEpochMat]');

pcaUnitEpochStruc.coeff = coeff;
pcaUnitEpochStruc.score = score;
pcaUnitEpochStruc.latent = latent;
pcaUnitEpochStruc.tsquared =  tsquared;
pcaUnitEpochStruc.explained =  explained;
pcaUnitEpochStruc.mu = mu;

% plot first 3 pcs
figure; 
subplot(1,2,1); 
plot(coeff(1:33, 1:3)); 
subplot(1,2,2); 
plot(coeff(34:66, 1:3));