function plotStage1cell()

% Clay Dec. 2018, on HenServer
% To plot output saved from findStage1geno.m

load('/Backup20TB/clay/brunoLab/2p mouse behavior/Rbp4/Rbp4_stage1data_112918a.mat');

stage1rewCa=[]; figure;
for i=1:size(stage1cell,1)
   rewCa = stage1cell{i,4}.rewTimeCa; 
   if size(rewCa,1)==33 && isempty(strfind(stage1cell{i,1},'R14')) % R14 animals are bad
      subplot(5,5,i);
      
      plotMeanSEMshaderr(rewCa, 'b');
      title(stage1cell{i,3});
      stage1rewCa = [stage1rewCa rewCa]; 
   end
end



