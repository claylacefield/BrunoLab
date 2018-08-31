function [minMaxYX] = calcUnitSpatDims(a)

% USAGE: [minMaxYX] = calcUnitSpatDims(a);
% Calculate maximum dimensions of a (reshaped) NMF factor
% (mostly for dendrites)
% This can be used for neuron shape calculations (e.g. area, direction)

% zero all values below a certain threshold
thresh = 0.2;
a(a<thresh*(max(a(:))))=0; % 

xAv = mean(a,2);
yAv = mean(a,1);

figure; plot(xAv); hold on; plot(yAv);


% find the max/min dimensions
maxX = find(xAv>0,1, 'last');
minX = find(xAv>0,1, 'first');

maxY = find(yAv>0,1, 'last');
minY = find(yAv>0,1, 'first');

minMaxYX = [minY maxY; minX maxX];


% But this method won't allow shape calculations