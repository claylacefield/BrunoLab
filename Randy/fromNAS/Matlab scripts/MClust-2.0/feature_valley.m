function [valleyData, valleyNames] = feature_valley(V, ttChannelValidity)

% MClust
% [valleyData, valleyNames] = feature_valley(V, ttChannelValidity)
% Calculate valley feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nCh valley values
%    Names - "valley: Ch"
%
% ADR April 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

valleyData = zeros(nSpikes, length(f));
valleyNames = cell(length(f), 1);

for iCh = 1:length(f)
   valleyData(:, iCh) = min(squeeze(TTData(:, f(iCh), :)), [], 2);
   valleyNames{iCh} = ['valley: ' num2str(f(iCh))];
end
