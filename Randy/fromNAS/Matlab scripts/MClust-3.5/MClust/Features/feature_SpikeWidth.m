function [SpikeWidthData, SpikeWidthNames,SpikeWidthPars] = feature_SpikeWidth(V, ttChannelValidity, Params)

% MClust
% [SpikeWidthData, SpikeWidthNames] = feature_SpikeWidthPars(V, ttChannelValidity)
% Calculate peak feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nCh peak values
%    Names - "SpikeWidth: Ch"
%
% ADR April 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

SpikeWidthData = zeros(nSpikes, length(f));
SpikeWidthNames = cell(length(f), 1);
SpikeWidthPars = {};
for iCh = 1:length(f)
    D = TTData(:, f(iCh), :);
    [peak, ipeak] = max(D, [], 3);
    [vlly, ivlly] = min(D, [], 3);
    
	SpikeWidthData(:,iCh) = squeeze(ivlly - ipeak);
	SpikeWidthNames{iCh} = ['SpikeWidth: ' num2str(f(iCh))];
end
