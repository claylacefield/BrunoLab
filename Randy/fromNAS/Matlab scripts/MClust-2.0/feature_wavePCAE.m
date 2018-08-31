function [wavePCData, wavePCNames] = feature_wavePCA(V, ttChannelValidity)

% MClust
% [Data, Names] = feature_wavePCA(V, ttChannelValidity)
% Calculate first FIVE waveform PRINCIPAL COMPONENTS 
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nPC*nCh  of waveform PCs of each spike for each valid channel
%    Names - "wavePCn: Ch"
%
% PL 1999 
% version 0.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

%%% PARAMETERS:  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nPC  = 5;    % number of principal components to keep (per channel)
norm = 0;    % normalize Waveforms (1) or don't normalize (0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

if norm
   % normalize waveforms to unit L2 norm (so that only their SHAPE or
   % relative angles but not their length (energy) matters)
   l2norms = sqrt(sum(TTData.^2,3));
   TTData = TTData./l2norms(:,:,ones(1,nSamp));
end%if


f = find(ttChannelValidity);
lf = length(f);

wavePCNames = cell(lf*nPC, 1); 
wavePCData  = zeros(nSpikes, lf*nPC);
I = ones(nSpikes,1);

for iC = 1:lf
   w = squeeze(TTData(:,f(iC),:));    % get data in nSpikes x nSamp array
   cv = cov(w);
   sd = sqrt(diag(cv))';        % row std vector
   av = mean(w);                % row mean vector
   pc = wavePCA(cv);            % get PCA eigenvectors (in columns of pc)
   wstd=(w-(I*av))./(I*sd);     % standardize data to zero mean and unit variance
   wpc = wstd*pc;               % project data onto principal component axes
   wavePCData(:,(iC-1)*nPC+1:iC*nPC) = wpc(:,1:nPC);
   for iPC = 1:nPC
      wavePCNames{(iC-1)*nPC + iPC} = ['wavePC' num2str(iPC) ': ' num2str(f(iC))];
   end
end
