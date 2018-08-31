function TT = LoadTT_sun(fn)

% TT = LoadTT_sun(fn)
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
% uses mex file LoadTT0_sun(fn) to do the main read.
%
% ADR 1998
% version L5.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

[t, wv] = LoadTT0_sun(fn);
TT = tsd(t, wv);