function sortedCA = sortcell(stringCA, k)

% sortedCA = sortcell(stringCA)
%
% sorts a cell array of strings
%
% INPUTS
%    stringCA = a cell array of strings
%    k (opt) = line[s] on which to sort on
%
% OUTPUTS
%    sortedCA = a cell array of strings
%
% ADR 1998
% version 1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


if nargin == 1
   sortedCA = cellstr(sortrows(char(stringCA)));
else
   sortedCA = cellstr(sortrows(char(stringCA), k));
end