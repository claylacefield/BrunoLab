function [segNum, segStruc, goodSeg] = segSelecEvents(maxCoeffSegStruc, numDend)



% this script takes the single-dend linear regression output
% (segLinRegStruc) and finds the segStruc file for all dendrites with a
% particular selectivity (based upon the linear regression, e.g. "reward").


cageFolder = '/home/clay/Documents/Data/2p mouse behavior/Rbp4/R5';      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

mouseNameStruc = cageDir([cageDir.isdir]);
mouseNameStruc = mouseNameStruc(3:end); % don't take the root dirs
mouseNameCell = {mouseNameStruc.name};


mouse = maxCoeffSegStruc(numDend).mouse;
% session = maxCoeffSegStruc(numDend).session;
seg = maxCoeffSegStruc(numDend).seg;
Rsqr = maxCoeffSegStruc(numDend).Rsqr;
name = maxCoeffSegStruc(numDend).name;

% move to correct session folder for this dendrite
cd([cageFolder '/' mouseNameCell{mouse} '/' name(1:end-4) '/' name ]); 

% load in the segStruc (latest one) and goodSeg
% NOTE: can make this faster by vectorizing?

tifDir = dir;

for d = 3:length(tifDir)
    if ~isempty(strfind(tifDir(d).name, 'seg_06-Jan-2014'))
        %disp(['loading in latest segmented file: ' tifDir(d).name]);
        segStruc = importdata(tifDir(d).name);
        goodSeg = importdata('goodSeg.mat');
    end
end

% NOTE: that seg # is vs. goodSeg

segNum = goodSeg(seg);  % now segNum = the absolute segment number (of 50)



