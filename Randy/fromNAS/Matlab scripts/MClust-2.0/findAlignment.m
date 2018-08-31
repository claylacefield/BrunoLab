function ix = findAlignment(D, tstmp)

% tsArray/findAlignment
% 	ix = findAlignment(D, tstmp)
%
% 	Returns an index i= such that D(ix) occurs 
%		at timestamp tstmp
% 	Finds closest index.
%
% ADR
% version: L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

nIX = length(tstmp);

ix = zeros(size(tstmp));
for iIX = 1:nIX
   ix(iIX) = binsearch(D.t, tstmp(iIX));
end
