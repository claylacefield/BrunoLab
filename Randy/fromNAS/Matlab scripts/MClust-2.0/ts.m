function tsa = ts(t)
%
% TSD = ts(t)
%
% A ts object contains a sequence of timestamps as
% might be stored in an NSMA t-file.
%
% Methods
%    ts/Data         - Returns the timestamps as a matlab array
%    ts/StartTime    - First timestamp
%    ts/EndTime      - Last timestamp
%    ts/Restrict      - Keep timestamps within a certain range
%
% ADR 1998
% version L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if nargin == 0
   ts.t = [];
   return
end

tsa.t = t;
tsa = class(tsa, 'ts');