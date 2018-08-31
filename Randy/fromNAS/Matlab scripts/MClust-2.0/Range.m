function R = Range(tsa, tsflag)

% tsd/Range
% 
%  R = Range(tsa)
%  R = Range(tsa, 'sec')
%  R = Range(tsa, 'ts')
%  R = Range(tsa. 'all_ts')
%
%  returns range covered by tsa
%      tsflag: if 'ts' returns time in timestamps (default),
%              if 'sec' returns time in sec
%              if 'sec0' returns time in sec counting from 0
%              if 'ms' returns time in ms
%              if 'all_ts', then range returns all timestamps in range
%
% ADR 
% version L4.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if nargin == 2
   switch (tsflag)
   case 'sec'
      R = tsa.t/10000;
   case 'sec0'
      R = (tsa.t - StartTime(tsa))/10000;
   case 'ts'
      R = tsa.t;
   case 'ms'
      R = tsa.t/10;
   case 'all_ts'
      R = StartTime(tsa.t):EndTime(tsa.t);
   otherwise
      error('Range called with invalid tsflag.');
   end
end

