function ProcessTTnt(TTfname, CLfname, nTrodes)
%
% function ProcessTTnr(TTfname, CLfname, nTrodes)
% 
% DO NOT CALL THIS DIRECTLY.  CALL ProcessTT instead.
%
% Creates T files from a given TT file and a coresponding TT.clusters file.
%
% INPUT:
%      TTfname  ... Cheetah TT filename (string)
%      CLfname  ... MClust .cluster file name (string) (optional)
%
% ADR 2000 from code by PL 1999
% Version: 1.0 
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

global MClust_Clusters;
global MClust_FeatureNames;
global MClust_FeatureData;
global DisplayProgressHandle;

debugON = 0;

%---- initialize
nTrodes=4;		% 4 channels for tetrode
nSamplesPerSpike=32;	% number of samples per spike waveform per channel
RECSIZE = 48 + nTrodes*nSamplesPerSpike*2;  % size of a spike record (bytes)
SEGSIZE = 1000;    % # of records per file segment to be processed 

[dn,TfnBase] = fileparts(TTfname);

%--- load .cluster file associated with current TT file and extract feature info
if exist(CLfname, 'file')
   load(CLfname, 'MClust_Clusters', ...
      'MClust_FeatureNames', 'MClust_ChannelValidity', 'featuresToUse', '-mat');
   if isa(MClust_Clusters{1},'precut')
      errordlg(['Cluster file "' CLfname '" contains PRECUT clusters! ' ...
            'Go back to MClust and convert PRECUT clusters to CONVEXHULL clusters by ' ...
            'selecting "Cut: Convex Hulls" button before "Save Clusters" or ' ...
            ' "Write Files" button!'], ... 
         'TT2T Error'); 
      return;
   end%if
   if debugON
      disp(['Cluster file ' CLfname  ' loaded!']);
   end
   orig_FeatureNames = MClust_FeatureNames;
else
   errordlg(['No cluster file "' CLfname '" found! Check path and try again!!!'], ... 
      'TT2T Error');
   return;    %abort
end%if
% [Features, ttChannelValidity] = ExtractFeaturesAndChannels(MClust_FeatureNames);
if debugON
   disp('Features To Use:');
   disp(featuresToUse);
   disp('Channel Validity:');
   disp(MClust_ChannelValidity);
end%if


%---- Open TT file
if ~exist(TTfname, 'file')
   errordlg(['No TT file "' TTfname '" found! Check path and try again!!!'], ...
         'TT2T Error');
   return;    %abort
end%if
[fp, msg] = fopen(TTfname,'rb','n');
if (fp == -1) 
   error(['Error opening file "' TTfname '" : ' msg]); 
end%if
[tmpdn, tmpfn] = fileparts(TTfname);
[tmpcdn, tmpcfn, tmpext] = fileparts(CLfname);
TTWindowName = ['Processing ' tmpfn ' via ' tmpcfn];      % Progress Window Text Display 


%---- Read Header
%% H = ReadHeader(fp);
fStart = ftell(fp);    % memorize start position after header


%--- get TT file size (after header)
whambang = fseek(fp,0,'eof');   
if whambang 
   [mess, errnum] = ferror(fp); 
   errordlg(['Something is fatally wrong with current TT file:' ...
         mess , ' ErrNo: ', num2str(errnum)], 'TT2T Error'); 
   return; 
end%if 
eofPos = ftell(fp);
fSize = eofPos - fStart;    % file size in bytes
fseek(fp,fStart,'bof');     % rewind to file start position (after header)
nRecsInFile = floor(fSize/RECSIZE);
lastRecSize = mod(fSize,RECSIZE);
if lastRecSize > 0
   warning(sprintf('File %s has an incomplete last record of size %i bytes. It is ignored!',...
      tmpfn, lastRecSize));
end%if


%--- split large files into manageable segments
nSeg = floor(nRecsInFile/SEGSIZE);
lastSegSize = mod(nRecsInFile, SEGSIZE);
if lastSegSize; nSeg = nSeg+1; end%if


%--- define segment arrays
ts = zeros(SEGSIZE,1);                             % timestamps
param = zeros(SEGSIZE,10);                         % parameters
wf = zeros(SEGSIZE, nTrodes, nSamplesPerSpike);    % waveform data

%--- start Progress Window
clear global DisplayProgressHandle;   % in case an old one is still hanging around...
DisplayProgress(0, 3*nSeg, 'Title', TTWindowName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  main loop over file segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iSeg = 1:nSeg   
   
   %--- determine Segment size (for last segment only)
   if iSeg == nSeg
      if lastSegSize
         SEGSIZE = lastSegSize;
         ts = zeros(SEGSIZE, 1); 
         param = zeros(SEGSIZE,10);
         wf = zeros(SEGSIZE, nTrodes, nSamplesPerSpike);    
      end%if
   end%if
       
   %--- Read Segment
   if (debugON); disp(sprintf('Reading Segment %i of size %i', iSeg, SEGSIZE)); end
   for iRec = 1:SEGSIZE
      ts(iRec)     = fread(fp, 1 , 'int64' )/100;   
      param(iRec,:)  = fread(fp, [1,10] , 'int32' );
      wf(iRec,:,:) = ...
         fread(fp, [nTrodes, nSamplesPerSpike], 'int16' );
   end%for
   
   %--- check for ascending order of timestamps and sort if necessary
   invTickSum = sum(diff(ts(1:SEGSIZE) < 0));
   if invTickSum ~= 0
      errstr = sprintf('File %s segment %i contains %i DECREASING time stamps!!', ... 
         tmpfn, iSeg, invTickSum);
      warning(errstr);
      disp(' Sorting file segment in increasing order of timestamps ...');
      [ts,iSorted] = sort(ts);
      wf = wf(iSorted,:,:);
      disp(' Done sorting. Check integrity of data! Never trust the programmer ...\n');
   end%if
   
   %--- make this file segment to a tsd object
   TT = tsd(ts, wf);
   
   DisplayProgress(3*(iSeg-1)+1, 3*nSeg, 'Title', TTWindowName);
   %%%%%%%% DONE READING SEGMENT
   
   
   %--- calculate features
   MClust_FeatureData = [];
   MClust_FeatureNames = {};
   nFeatures = length(featuresToUse);
   for iF = 1:nFeatures
      [nextFeatureData, nextFeatureNames] = ...
         feval(['feature_', featuresToUse{iF}], TT, MClust_ChannelValidity);
      MClust_FeatureData = [MClust_FeatureData nextFeatureData];
      MClust_FeatureNames = [MClust_FeatureNames; nextFeatureNames];
   end
   
   if debugON 
      if iSeg == 1
         disp(' Original Feature Names');
         disp(orig_FeatureNames);
         disp(' Present Feature Names');
         disp(MClust_FeatureNames);
      end%if
      disp(' Size of Feature Data:');
      disp( size(MClust_FeatureData));
   end%if
   
   DisplayProgress(3*(iSeg-1)+2, 3*nSeg, 'Title', TTWindowName);
   %%%%%%% DONE CALCULATING FEATURES
   
   
   %--- Process clusters and write/append to output files
   act = 'app';
   if iSeg == 1; act = 'ini'; end%if
   [basedn, basefn, ext] = fileparts(TfnBase);
   clusterIndex = WriteTFiles2(fullfile(basedn, basefn), ...
      TT, MClust_FeatureData, MClust_Clusters, act);
   WriteClusterIndexFile2([fullfile(basedn, basefn), '.cut'], clusterIndex, act);
   
   DisplayProgress(3*(iSeg-1)+3, 3*nSeg, 'Title', TTWindowName);
   %%%%%%%% DONE PROCESSING AND WRITING
   
end%for iSeg = 1:nSeg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  end main loop over file segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fp);

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     local helper functions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [featureCallList, ValidChannels] = ExtractFeaturesAndChannels(fn)
% 
% extract the features and the valid Channels from MClust's FeatureNames
%
% INPUT: fn ... cell array of feature name strings as provided by MClust
% 
% OUTPUT: 
%     featureCallList ..... cell array of 'feature_name.m' function names
%     ValidChannels ... boolean [4 1] array of switched on (1) and off (0) channels
%
%
% WARNING: relies heavily on naming convention of MCLUSTS feature names!
%          If all included features  don't stick to MClust's convention
%          of 'fname: channelID' ALL channels are included!!

% CCC: PL
%%%

ValidChannels = [0; 0; 0; 0];

%%% Create LookUp table with feature file names and feature 'titles' in MClust.
%%% Currently, new features have to be include here by hand!!! SORRY!!!
%%%
%   FLAG          FEATURE TITLE             FILE NAME (excluding: feature_)
ff(1) = 0;     ft{1} = 'Area';           ffn{1} = 'area'; 
ff(2) = 0;     ft{2} = 'energy';         ffn{2} = 'energy';
ff(3) = 0;     ft{3} = 'Peak/Valley';    ffn{3} = 'p2v_ratio';
ff(4) = 0;     ft{4} = 'Peak';           ffn{4} = 'peak';
ff(5) = 0;     ft{5} = 'SW';             ffn{5} = 'sw';
ff(6) = 0;     ft{6} = 'time (ts)';      ffn{6} = 'time';
ff(7) = 0;     ft{7} = 'valley';         ffn{7} = 'valley';
ff(8) = 0;     ft{8} = 'waveform';       ffn{8} = 'waveform';
%ff(9) = 0;     ft(9) = 'wavePCA';        ffn(9) = 'wavePCA';
%ff(10)= 0;     ft(10)= 'wavePC1';        ffn(10)= 'wavePC1';
%ff(11)= 0;     ft(11)= 'wavePC2';        ffn(11)= 'wavePC2';
%ff(12)= 0;     ft(12)= 'wavePC3';        ffn(12)= 'wavePC3';
%ff(13)= 0;     ft(13)= 'wavePCVM';       ffn(13)= 'wavePCVM';
%ff(14)= 0;     ft(14)= 'wavePC2';        ffn(14)= 'totalPCA';

for line = 1:length(fn)
   [fTitle, rest] = strtok(fn{line},':');
   
   %--- find fTitle in lookup table and set corresponding flag
   i = strmatch(fTitle,ft,'exact');
   if ~i
      error(['ExtractFeaturesAndChannels could not find the feature: ' fTitle]);
   end%if
   ff(i) = 1;
   
   %--- extract channel
   if rest
      chNum = str2num(rest(2:end));
      if (chNum>=1 & chNum<=4)
         % assume this channel was selected as Valid Channel
         ValidChannels(chNum) = 1;
      end%if
   end%if
end%for line


if ~sum(ValidChannels)
   error([' Could NOT identify any valid channel' ... 
      'in .cluster file!!! Include Features with channel ID!!']);   
end%if

%--- create a sorted featureCallList
featureCallList = cellstr(sortrows(char( ffn(find(ff)) ))); 

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function clusterIndex = WriteTFiles2(basefn, TT, featureData, clusters, act)
%%
% WriteTFiles2(basefn, TT, clusters, act)
%
% MClust
%  writes a T-file for each cluster
% 
% Modified to allow for 'append'  write mode of multiple segments into same file.
% Also, return clusterIndex info anologous to ProcessClusters.m 
%
%  act = 'ini' ... create/overwrite new file and write header
%        'app' ... append to exisiting file (write no header)

% 
% CCC: PL

debugON = 0;

nClust = length(clusters);
timestamps = Range(TT, 'ts');

[nSamps, nDims] = size(featureData);
clusterIndex = zeros(nSamps,1);

for iC = 1:nClust

   %--- open appropriate file in overwrite or append mode
   fn = [basefn '_' num2str(iC) '.t'];
   if act == 'ini'
      fp = fopen(fn, 'wb', 'b');
      WriteHeader(fp, 'T-file', 'Output from MClust');
   elseif act == 'app'
      fp = fopen(fn, 'ab', 'b');
   else
      errordlg(['No action for act = "' act '".']); 
   end%if
   if (fp == -1)
      errordlg(['Could not open file"' fn '".']);
      keyboard;
   end
   
   %---  find spikes in current cluster and write/append timestamps
   f = FindInCluster(clusters{iC}, featureData);
   if ~isempty(f)
      TS = timestamps(f);      
      fwrite(fp, TS, 'uint32');
      
      if debugON
         msg = sprintf('Wrote to file "%s" %i timestamp(s). FilePointer = %i' ,...
            fn, length(TS), ftell(fp));
         disp(msg);
      end%if      
   end%if
   
   %--- find and return timestamp inidices of cluster members
   f2 = find(clusterIndex(f)>0);
   clusterIndex(f) = iC;
   clusterIndex(f2) = -1;
   
   %--- cleanup
   fclose(fp);

end%for iC


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function WriteClusterIndexFile2(fn, clusterIndex, act)

% WriteClusterIndexFile2(fn, clusterIndex, act)
%
% MClust
%  format is just an ascii list of which cluster each elt belongs to
% 
% 
% ADR 1998
% version M1.0
% modified to allow for 'append' mode for multiple writes into the same file
% CCC: PL

if act == 'ini'
   fp = fopen(fn, 'wt');
elseif act == 'app'
   fp = fopen(fn, 'at');
else
  errordlg(['No action for act = "' act '".']); 
end%if

if fp == -1
   errordlg(['Could not open file"' fn '".']);
   return;
end

if act == 'ini'
   WriteHeader(fp, ...
      'Cluster Index File', ...
      'Output from MClust', ...
      'Format = ascii file of which cluster each element belongs to');
end%if

fprintf(fp, '%d\n', clusterIndex);
fclose(fp);

return;
