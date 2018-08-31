function ts = findTime(D, ix)
%
% ctsd/findTime
% 	ix = findTime(D, ix)
%
% 	Returns timestamsp at which index ix occues
%
% ADR 1998
% version L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

ts = D.t(ix);