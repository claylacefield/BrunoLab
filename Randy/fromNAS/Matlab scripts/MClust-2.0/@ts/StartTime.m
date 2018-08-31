function t = StartTime(TS, tsflag)

% ts/StartTime
% t = StartTime(TS, tsflag)
%
% returns first timestamp in TS
%      tsflag: if 'ts' returns time in timestamps (default),
%              if 'sec' returns time in sec
%              if 'ms' returns time in ms
%
%
% ADR 1998
% version L4.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if isempty(TS.t) 
   t = NaN;
else
   t = min(TS.t);
   
   if nargin == 2
      switch tsflag
      case 'sec'
         t = t/10000;
      case 'ms'
         t = t/10;
      case 'ts'
      otherwise
         error('Unknown tsflag.');
      end
   end

end