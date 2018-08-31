function SplitTTsun(TTfname, CLfname)
% SplitTTsun(TTfname, CLfname)
%
% DO NOT CALL THIS DIRECTLY.  USE SplitTT instead.
%
% Creates two new TT files from a given TT file and a coresponding TT.clusters file.
% INPUT:
%      TTfname  ... Cheetah TT filename (string)
%      CLfname  ... MClust .cluster file name (string)
%
%
% ADR 1999, modified from code by Peter Lipa
% Version: 1.0 (June.1999)
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
RECSIZE = 4 + nTrodes*nSamplesPerSpike*2;  % size of a spike record (bytes)
SEGSIZE = 1000;    % # of records per file segment to be processed 


%--- load .cluster file associated with current TT file and extract feature info
if exist(CLfname, 'file')
   load(CLfname, 'MClust_Clusters', ...
      'MClust_FeatureNames', 'MClust_ChannelValidity', 'featuresToUse', '-mat');
   if isa(MClust_Clusters{1},'precut')
      errordlg(['Cluster file "' CLfname '" contains PRECUT clusters! ' ...
            'Go back to MClust and convert PRECUT clusters to CONVEXHULL clusters by ' ...
            'selecting "Cut: Convex Hulls" button before "Save Clusters" or ' ...
            ' "Write Files" button!'], ... 
         'SplitTT Error'); 
      return;
   end%if
   orig_FeatureNames = MClust_FeatureNames;
else
   errordlg(['No cluster file "' CLfname '" found! Check path and try again!!!'], ... 
      'SplitTT Error');
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
         'SplitTT Error');
   return;    %abort
end%if
[fp, msg] = fopen(TTfname,'rb','b');
if (fp == -1) 
   error(['Error opening file "' TTfname '" : ' msg]); 
end%if
[tmpdn, tmpfn] = fileparts(TTfname);
[tmpcdn, tmpcfn, tmpext] = fileparts(CLfname);
TTWindowName = ['SplitTT:' tmpfn ' by ' tmpcfn];      % Progress Window Text Display 
TTfn = tmpfn;


%---- Read Header
H = ReadHeader(fp);
fStart = ftell(fp);    % memorize start position after header


%--- get TT file size (after header)
whambang = fseek(fp,0,'eof');   
if whambang 
   [mess, errnum] = ferror(fp); 
   errordlg(['Something is fatally wrong with current TT file:' ...
         mess , ' ErrNo: ', num2str(errnum)], 'SplitTT Error'); 
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
wf = zeros(SEGSIZE, nTrodes, nSamplesPerSpike);    % waveform data

%--- start Progress Window
clear global DisplayProgressHandle;   % in case an old one is still hanging around...
DisplayProgress(0, 3*nSeg, 'Title', TTWindowName);

%--- open files and write headers
nClusters = length(MClust_Clusters);
for iClust = 1:nClusters
   tmpfn = [TTfn 'Split' num2str(iClust,'%02d') '.tt'];
   [newTTfp{iClust},msg] = fopen(tmpfn, 'wb', 'b');
   if newTTfp{iClust} == -1; error(['SplitTT error: ' msg]); end
   WriteHeader(newTTfp{iClust}, 'Spikes in clusters', ['Cluster ' num2str(iClust)], ['Split from ' TTfname ' by ' CLfname]);
   frewind(newTTfp{iClust}); H = ReadHeader(newTTfp{iClust});
end

[newTTfpOUT,msg] = fopen([TTfn 'Splitout.tt'], 'wb', 'b');
if newTTfpOUT == -1; error(['SplitTT error: ' msg]); end
WriteHeader(newTTfpOUT, 'Spikes out of clusters', ['Split from ' TTfname ' by ' CLfname]);
frewind(newTTfpOUT); H = ReadHeader(newTTfpOUT);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  main loop over file segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iSeg = 1:nSeg   
   
   %--- determine Segment size (for last segment only)
   if iSeg == nSeg
      if lastSegSize
         SEGSIZE = lastSegSize;
         ts = zeros(SEGSIZE, 1);                           
         wf = zeros(SEGSIZE, nTrodes, nSamplesPerSpike);    
      end%if
   end%if
       
   %--- Read Segment
   if (debugON); disp(sprintf('Reading Segment %i of size %i', iSeg, SEGSIZE)); end
   for iRec = 1:SEGSIZE
      ts(iRec)     = fread(fp, 1 , 'int32' );   
      wf(iRec,:,:) = ...
         fread(fp, [nTrodes, nSamplesPerSpike], 'int16' );
   end%for
   
   %--- check for ascending order of timestamps and sort if necessary
   %invTickSum = sum(diff(ts(1:SEGSIZE) < 0));
   %if invTickSum ~= 0
   %   errstr = sprintf('File %s segment %i contains %i DECREASING time stamps!!', ... 
   %      tmpfn, iSeg, invTickSum);
   %   warning(errstr);
   %   disp(' Sorting file segment in increasing order of timestamps ...');
   %   [ts,iSorted] = sort(ts);
   %   wf = wf(iSorted,:,:);
   %   disp(' Done sorting. Check integrity of data! Never trust the programmer ...\n');
   %end%if
   
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
   
   
   %--- Process clusters 
   keep = zeros(SEGSIZE, 1);
   for iClust = 1:nClusters
      f = FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData);
      keep(f) = 1;
      for iRec = f'
         fwrite(newTTfp{iClust}, ts(iRec), 'int32');
         fwrite(newTTfp{iClust}, wf(iRec,:,:), 'int16');
      end
   end
        
   %--- Write nokeep file
   for iRec = find(~keep)'
      fwrite(newTTfpOUT, ts(iRec), 'int32');
      fwrite(newTTfpOUT, wf(iRec,:,:), 'int16');
   end      
   
   DisplayProgress(3*(iSeg-1)+3, 3*nSeg, 'Title', TTWindowName);
   %%%%%%%% DONE PROCESSING AND WRITING
   
end%for iSeg = 1:nSeg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  end main loop over file segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fclose(fp);

for iClust = 1:nClusters
   fclose(newTTfp{iClust});
end

fclose(newTTfpOUT);

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


