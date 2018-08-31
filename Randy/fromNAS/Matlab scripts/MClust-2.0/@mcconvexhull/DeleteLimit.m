function MCC = DeleteLimit(MCC, xdim, ydim)

% MCCluster/DeleteLimit(MCC, xdim, ydim)
%
% INPUTS
%    xdim - xdimension
%    ydim - ydimension
%
% ADR 1998
% version M1.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if ~isempty(MCC.xdims)
   iL = find(MCC.xdims == xdim & MCC.ydims == ydim);
   if ~isempty(iL)
      MCC.xdims = MCC.xdims([1:(iL-1) (iL+1):end]);
      MCC.ydims = MCC.ydims([1:(iL-1) (iL+1):end]);
      MCC.cx    = MCC.cx([1:(iL-1) (iL+1):end]);
      MCC.cy    = MCC.cy([1:(iL-1) (iL+1):end]);
   end
end

if MCC.recalc == 0
   MCC.recalc = 1;
end
