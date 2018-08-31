function rasterdelta(cluster)
% RASTERDELTA(CLUSTER) Plot spikes as a series of delta functions
%
% INPUTS
% cluster: a standard cluster data structure containing a cluster file
%           already read in; assumes cluster contains only 1 trial
%
% Randy Bruno, May 2004

timestamp = cluster(:, 4);
n = length(timestamp)

timestamp = reshape([timestamp timestamp timestamp]', 3*n, 1);
y = repmat([0 1 0]', n, 1);

line(timestamp, y);
