function clusterIndex = ProcessClusters(data, clusters)

% clusterIndex = ProcessClusters(data, clusters)
%
% INPUT:
%   data - MClust feature data
%   clusters - MClust cluster objects
% OUTPUT:
%   index showing to which cluster each spike belongs
%   spikes belonging to multiple clusters get assigned the error signal -1
%
% ADR 1999
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


[nSamps, nDims] = size(data);
clusterIndex = zeros(nSamps,1);
for iC = 1:length(clusters)
   f = FindInCluster(clusters{iC}, data);
   f2 = find(clusterIndex(f)>0);
   clusterIndex(f) = iC;
   clusterIndex(f2) = -1;
end
