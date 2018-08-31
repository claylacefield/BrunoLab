function dt = DT(tsa)
%
% dt = tsd/DT(tsd, tsflag)
%	returns DT from tsa
% INPUTS
%      tsd 
%      tsflag: if 'ts' returns time in timestamps (default),
%              if 'sec' returns time in sec
%              if 'ms' returns time in ms
%
% ADR 1998
% version L1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

dt = mean(diff(tsa.t));

if nargin == 2
   switch tsflag
   case 'sec'
      dt = dt/10000;
   case 'ms'
      dt = dt/10;
   case 'ts'
   otherwise
      error('Unknown tsflag.');
   end
end
