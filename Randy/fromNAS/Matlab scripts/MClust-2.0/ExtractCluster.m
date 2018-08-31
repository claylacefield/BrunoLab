function clustTT = ExtractCluster(TT, clusterIndex)

% MClust/ExtractCluster
%
% INPUTS
%    TT -- TT tsd
%    clusterIndex - output of FindInCluster
%  
% OUTPUTS
%    clustTT -- TT tsd containing only those points in cluster
%
% ADR 1999
% Version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


TTtimestamps = Range(TT, 'ts');
TTdata = Data(TT);
clustTT = tsd(ts(TTtimestamps(clusterIndex)), TTdata(clusterIndex,:,:));
