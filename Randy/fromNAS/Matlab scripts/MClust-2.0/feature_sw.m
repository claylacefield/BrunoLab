function [SWData, SWNames] = feature_SpikeWidth(V, ttChannelValidity)

% MClust
% [Data, Names] = feature_SW(V, ttChannelValidity)
% Calculate area feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nCh of spikewidth of each spike
%    Names - "SW: Ch"
%
% ADR April 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

sw = SpikeWidth(V);
[nSpikes, nCh, nSamp] = size(Data(V));
f = find(ttChannelValidity);

SWData = zeros(nSpikes, length(f));
SWNames = cell(length(f), 1);

for iCh = 1:length(f)
   SWData(:, iCh) = sw(:,f(iCh));
   SWNames{iCh} = ['SW: ' num2str(f(iCh))];
end
