

% 082917
% for making itiWhiskBoutCa vs. rew4/randRew Ca plot
% for paper

% (on laptop)

load('C:\Users\Clay\Desktop\BarrelCortexDesktop\dendriteAnalysis2017\itiWhiskBoutCaMouseStruc_mouseR135_05-Feb-2017.mat');


% load('C:\Users\Clay\Documents\Bruno lab\dendritePaper\frameData\rewDelayGroup_44goodSess_012115a.mat');
load('C:\Users\Clay\Documents\Bruno lab\dendritePaper\frameData\rewDelayGroup_052114a.mat');



itiWhiskBoutCa = itiWhiskBoutCaMouseStruc.itiWhiskBoutCa;
itiWhiskBoutAngle = itiWhiskBoutCaMouseStruc.itiWhiskBoutAngle;
itiWhiskBoutVar = itiWhiskBoutCaMouseStruc.itiWhiskBoutVar;



figure; 
line([0 0], [-0.05 0.08]); 
hold on; 
% plotMeanSEMshaderr(outStruc.rewTime4CaAvg, 'b'); 
plotMeanSEMshaderr(group1Struc.rewTime4CaAvg, 'b', 9); 
plotMeanSEMshaderr(itiWhiskBoutCaMouseStruc.itiWhiskBoutCa, 'g', 9);

figure; plotMeanSEMshaderr(itiWhiskBoutAngle, 'g', 9);




