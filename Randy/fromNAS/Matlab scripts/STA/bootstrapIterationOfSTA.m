function result = bootstrapIterationOfSTA(duration, averagingpath, limit, UpDownBorder, Vend, GreaterThan, Plots)
% This function is essentially an interface between the
% SpikeTriggerAverage.m function and the bootstrap procedure.
%
% Matlab's built-in bootstrap procedure is limitted: It does not allow
% matrices to be passed in without going through the resampling procedure.
% Therefore, the cluster matrix and the raw STA must be handled as global
% variables.
%
% Randy Bruno, March 2006

[x, shift, nshift, isis2, meanVm2, avgvar] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, UpDownBorder, Vend, GreaterThan, true, Plots);
result = rawy - shift;
