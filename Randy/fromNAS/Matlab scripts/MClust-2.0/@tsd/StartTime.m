function T1 = StartTime(tsa, tsflag)

% t = tsd/StartTime(tsd, tsflag)
%	returns first timestamp covered by tsa
% returns last timestamp in TS
%      tsflag: if 'ts' returns time in timestamps (default),
%              if 'sec' returns time in sec
%              if 'ms' returns time in ms
%% ADR
% version L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

T1 = min(tsa.t);

if nargin == 2
   switch tsflag
   case 'sec'
      T1 = T1/10000;
   case 'ms'
      T1 = T1/10;
   case 'ts'
   otherwise
      error('Unknown tsflag.');
   end
end
