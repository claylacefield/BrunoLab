function plotSomaDendStrucCa();

% Clay Nov. 2017
% plot frame averages for L234 soma/dend for paper.

cd('C:\Users\Clay\Desktop\BarrelCortexDesktop');
load('Cux2_groupDbsStrucs_3_10-Oct-2017.mat');
group1StrucS = group1Struc;
group2StrucD = group2Struc;
load('Nr5a_groupDbsStrucs_09-Oct-2017.mat');
group1Struc = group1Struc;


fieldName = 'correctRewStimIndCa';
baseInd = 9;

figure; hold on;
plotMeanSEMshaderr(group2StrucD.(fieldName), 'b', baseInd);
plotMeanSEMshaderr(group1StrucS.(fieldName), 'g', baseInd);
plotMeanSEMshaderr(group1Struc.(fieldName), 'r', baseInd);
