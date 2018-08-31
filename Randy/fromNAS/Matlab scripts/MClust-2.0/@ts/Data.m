function t = Data(TS, ts)

% @ts/Data:
% t = Data(TS, ts)
% t = Data(TS)
%
% if ts included then returns the value just beneath ts, 
% if ts not included, returns an unclassed array of the data in TS
%
% ADR
% version L4.2
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if nargin == 1
   t = TS.t;
else
   t = TS.t(binsearch(TS.t, ts));
end
