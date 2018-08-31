function WriteClusterIndexFile(fn, clusterIndex)

% WriteClusterIndexFile(fn, clusterIndex)
%
% MClust
%  format is just an ascii list of which cluster each elt belongs to
%
% ADR 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


fp = fopen(fn, 'wt');
if fp == -1
   errordlg(['Could not open file"' fn '".']);
   return;
end

WriteHeader(fp, ...
   'Cluster Index File', ...
   'Output from MClust', ...
   'Format = ascii file of which cluster each element belongs to');
fprintf(fp, '%d\n', clusterIndex);
fclose(fp);
