



% this script takes the single-dend linear regression output
% (segLinRegStruc) and finds the segStruc file for all dendrites with a
% particular selectivity (based upon the linear regression, e.g. "reward").


cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

mouseNameStruc = cageDir([cageDir.isdir]);
mouseNameStruc = mouseNameStruc(3:end); % don't take the root dirs
mouseNameCell = {mouseNameStruc.name};


mouse = maxCoeffSegStruc(numDend).mouse;
session = maxCoeffSegStruc(numDend).session;
seg = maxCoeffSegStruc(numDend).seg;
Rsqr = maxCoeffSegStruc(numDend).Rsqr;
name = maxCoeffSegStruc(numDend).name;

% move to correct session folder for this dendrite
cd([cageFolder '/' mouseNameCell{mouse} '/' name(1:end-4) '/' name ]); 

% load in the segStruc (latest one)

for d = 3:length(tifDir)
    if ~isempty(strfind(tifDir(d).name, 'seg_06-Jan-2014'))
        disp(['loading in latest segmented file: ' tifDir(d).name]);
        load(tifDir(d).name);
        load('goodSeg.mat');
    end
end

for i = 1:length(cageDir) 
   if cageDir(i).isdir  && ~isempty(strfind(cageDir(i).name, 'mouse')) 
    cd(cageDir(i).name);
    
   end
end
