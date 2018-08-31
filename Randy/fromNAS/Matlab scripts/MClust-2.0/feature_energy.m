function [energyData, energyNames] = feature_energy(V, ttChannelValidity)

% MClust
% [Data, Names] = feature_energy(V, ttChannelValidity)
% Calculate energy feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nCh of energy INSIDE curve (below peak and above valley) of each spike
%    Names - "energy: Ch"
%
% ADR April 1998
% version M1.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

energyData = zeros(nSpikes, length(f));
energyNames = cell(length(f), 1);

for iCh = 1:length(f)
   energyData(:, iCh) = sqrt(sum(squeeze( TTData(:, f(iCh), :) .* TTData(:, f(iCh), :) ), 2));
   energyNames{iCh} = ['energy: ' num2str(f(iCh))];
end
