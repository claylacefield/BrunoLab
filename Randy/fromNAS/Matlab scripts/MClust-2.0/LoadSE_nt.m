function SE = LoadSE_nt(fn)

% SE = LoadSE_nt(fn)
%
% Loads an NSMA SE file.
%
% INPUTS:
%   fn -- .SE file
%
% OUTPUTS:
%   SE is a tsd Structure 
%      where data = nSpikes x nSamplesPerSpike x nTrodes
%
% uses mex file LoadSE0_nt(fn) to do the main read.
% LoadSE0_nt written by PL 1999
%
% ADR 2000
% version L1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

[t, wv] = LoadSE0_nt(fn);
SE = tsd(t, wv);