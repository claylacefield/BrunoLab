function TT = LoadTT_nt(fn)

% TT = LoadTT_nt(fn)
%
% Loads an NSMA TT file.
%
% INPUTS:
%   fn -- .tt file
%
% OUTPUTS:
%   TT is a tsd structure 
%      where data = nSpikes x nSamplesPerSpike x nTrodes
%
% uses mex file LoadTT0_nt(fn) to do the main read.
% LoadTT0_nt written by PL 19999
%
% ADR 2000
% version L1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

[t, wv] = LoadTT0_nt(fn);
TT = tsd(t, wv);