function WriteTFiles(basefn, TT, featureData, clusters)

% WriteTFiles(basefn, TT, clusters)
%
% MClust
%  writes a T-file for each cluster
%
% ADR 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


nClust = length(clusters);
timestamps = Range(TT, 'ts');

for iC = 1:nClust
   DisplayProgress(iC, nClust, 'Title', 'Writing T files');
   f = FindInCluster(clusters{iC}, featureData);
   if ~isempty(f)
      TS = timestamps(f);
      fn = [basefn '_' num2str(iC) '.t'];
      fp = fopen(fn, 'wb', 'b');
      if (fp == -1)
         errordlg(['Could not open file"' fn '".']);
         keyboard;
      end
      WriteHeader(fp, 'T-file', 'Output from MClust');
      fwrite(fp, TS, 'uint32');
      fclose(fp);
   end
end