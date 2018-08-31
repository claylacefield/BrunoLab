function [selectedSpikes] = IdentifyCaBurstsForSTA(cluster, burstSpike, burstCrit)
% IDENTIFYCABURSTSFORSTA Identify selected burst spike in Ca++ bursts, generated in
% thalamocortical cells by hyperpolarizing pulses, for spike-triggered averaging of
% cortical Vm.
%
% INPUTS
% cluster: standard cluster table
% burstSpike: 1 = select first spike in burst, 2 = second, etc.
% burstCrit: interspike interval criterion for defining burst
%
% OUTPUTS
% selectedSpikes: a boolean vector indicating which spikes in cluster are the start
% of Ca++ bursts
%
% Randy Bruno, August 2004

if sum(ismember(burstSpike, 1:3)) == 0
    error('output defined only for burstSpike values of 1, 2 and 3');
end

ISI0 = ISIof(cluster);
ISI1 = [ISI0(2:end); NaN];
ISI2 = [ISI0(3:end); NaN; NaN];

% We define the 1st spike of a burst to have no ISI (first spike in trial)
% or an ISI that exceeds some criterion and at least two spikes following
% it at ISIs of less than the criterion.
% This line of code is more computationally efficient than looping through
% each spike.
firstspike = (isnan(ISI0) | ISI0 > burstCrit) & ISI1 < burstCrit & ISI2 < burstCrit;       

% shift array to select the n-th burstspike
selectedSpikes = [repmat(false, burstSpike-1, 1); firstspike(1:(end-burstSpike+1))];
