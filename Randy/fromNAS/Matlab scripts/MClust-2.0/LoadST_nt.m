function ST = LoadST_nt(fn)

% ST = LoadST_nt(fn)
%
% Loads an NSMA ST file.
%
% INPUTS:
%   fn -- .ST file
%
% OUTPUTS:
%   ST is a tsd structure 
%      where data = nSpikes x nSamplesPerSpike x nTrodes
%
% uses mex file LoadST0_nt(fn) to do the main read.
% LoadST0_nt written by PL 1999
%
% ADR 2000
% version L1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

[t, wv] = LoadST0_nt(fn);
ST = tsd(t, wv);