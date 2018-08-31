


% plot all traces with heat colormap

rewStimInd = group1Struc.rewStimStimIndCaAvg;
colors = jet(80);

figure; 
hold on; 
for i = 1:80 
    rawField = rewStimInd(:,i);
    baseline = mean(rawField(10),1);
    plot(rawField-baseline, 'Color', colors(i,:)); 
end


% Plan for finding source files for rewDelayGroup 052114
% - They had been selected by hand with GUI from R10,11
%   by looking at their normal stim reward calcium

% go through all files from a list of cages


% go through each animal in cage


% look through all days in animal folder
% look through all sessions in the day
% load in dendriteBehavStruc
% see if values match any of the files in that dBS match
%   the same field in the group1Struc
% if so, record the name, path to that file (and performance?)