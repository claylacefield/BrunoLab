function v = Data(tsa, ix)

% ctsd/Data
%   d = Data(tsa)
%   d = Data(tsa, alignments)
%	Retrieves data from ctsd
%   if called with alignment list (timestamps), returns those tsa.Data(ix)
%   if called without, returns complete tsa.Data
%
% ADR 1998
% version L4.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

switch nargin
case 2
   f = findAlignment(tsa, ix);
   v = SelectAlongFirstDimension(tsa.data,f);
  case 1
    v = tsa.data;
  otherwise
    error('Unknown number of input arguments');
end
