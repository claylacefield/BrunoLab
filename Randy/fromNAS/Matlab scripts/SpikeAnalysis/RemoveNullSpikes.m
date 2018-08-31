function out = RemoveNullSpikes(cluster)

% REMOVENULLSPIKES(CLUSTER) removes dummy spike records used to insure
% proper recording of trial and stimulation information. For example, no
% spike records would be recorded by ntrode.vi if a cell failed to fire.
% This would lead to loss of trial and stimulus code numbers. This scenario
% is prevented by the inclusion of a dummy spike that is recorded at the
% start of the trial.
% Randy Bruno, April 2003

out = cluster(cluster(:,4) > 0, :);
