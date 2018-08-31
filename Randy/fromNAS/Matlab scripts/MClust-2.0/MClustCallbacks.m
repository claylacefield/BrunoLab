function MClustCallbacks

% MClust
% MClustCallbacks
% 
% Contains all callbacks for the MClust main window (see MClust)
%
% This program stores a number of key parameters as global variables.
% All global variables start with the tag "MClust_".  The variables are
%    MClust_TTfn         % file name for tt file
%    MClust_TTdn         % directory name for tt file
%    MClust_TTData       % data from tt file
%    MClust_FeatureData  % features calculated from tt data
%    MClust_FeatureNames % names of features
%    MClust_ChannelValidity % 4 x 1 array of channel on (1) or off (0) flags
%    MClust_Clusters     % cell array of cluster objects 
% 
% See also
%    MClust
%
% ADR 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

% global variables
global MClust_TTfn         % file name for tt file
global MClust_TTdn         % directory name for tt file
global MClust_TTData       % data from tt file
global MClust_FeatureData  % features calculated from tt data
global MClust_FeatureNames % names of features
global MClust_ChannelValidity % 4 x 1 array of channel on (1) or off (0) flags
global MClust_Clusters     % cell array of cluster objects 

cboHandle = gcbo;                          % current uicontrol handle
figHandle = ParentFigureHandle(cboHandle); % current figure handle

switch get(cboHandle, 'Tag')
   
case 'InputType'
   ChHandle1 = findobj(figHandle, 'Tag', 'TTValidity1');
   ChHandle2 = findobj(figHandle, 'Tag', 'TTValidity2');
   ChHandle3 = findobj(figHandle, 'Tag', 'TTValidity3');
   ChHandle4 = findobj(figHandle, 'Tag', 'TTValidity4');
   
   switch get(cboHandle, 'value') 
   case {1,2} % TT 
      set(ChHandle1, 'value', 1, 'enable', 'on');
      set(ChHandle2, 'value', 1, 'enable', 'on');
      set(ChHandle3, 'value', 1, 'enable', 'on');
      set(ChHandle4, 'value', 1, 'enable', 'on');
   case 3 % ST
      set(ChHandle1, 'value', 1, 'enable', 'on');
      set(ChHandle2, 'value', 1, 'enable', 'on');
      set(ChHandle3, 'value', 0, 'enable', 'off');
      set(ChHandle4, 'value', 0, 'enable', 'off');
   case 4 % SE
      set(ChHandle1, 'value', 1, 'enable', 'on');
      set(ChHandle2, 'value', 0, 'enable', 'off');
      set(ChHandle3, 'value', 0, 'enable', 'off');
      set(ChHandle4, 'value', 0, 'enable', 'off');
   otherwise
      error('Internal error: Unknown Input type');
   end
   
case 'LoadTTFileButton'
   InputTypeHandle = findobj(figHandle, 'Tag', 'InputType');
   InputValue = get(InputTypeHandle, 'value');
   switch InputValue
   case 1 % TT sun
      expExtension = '*.tt';
   case 4 % SE nt
      expExtension = 'SE*.dat';
   case 3 % ST nt
      expExtension = 'ST*.dat';
   case 2 % TT nt
      expExtension = 'TT*.dat';
   otherwise
      error('Internal error: Unknown input file type.');
   end
   
   [MClust_TTfn, MClust_TTdn] = uigetfile(expExtension, 'TT file');
   if MClust_TTfn
      setptr(gcf, 'watch');
      [dn,fn,ext] = fileparts(MClust_TTfn);
      switch InputValue
      case 1 % TT sun
         MClust_TTData = LoadTT_sun(fullfile(MClust_TTdn, MClust_TTfn));
      case 2 % TT nt
         MClust_TTData = LoadTT_nt(fullfile(MClust_TTdn, MClust_TTfn));
      case 3 % ST nt
         MClust_TTData = LoadST_nt(fullfile(MClust_TTdn, MClust_TTfn));
      case 4 % SE nt
         MClust_TTData = LoadSE_nt(fullfile(MClust_TTdn, MClust_TTfn));
      end
         
      setptr(gcf, 'arrow');
      set(cboHandle, 'Value', 1);
   else
      set(cboHandle, 'Value', 0);
   end
   fnTextObj = findobj(figHandle, 'Tag', 'TTFileName');
   set(fnTextObj, 'String', MClust_TTfn);
   MClust_TTfn = fullfile(MClust_TTdn, MClust_TTfn);
   
case {'FeaturesUseListbox', 'FeaturesIgnoreListbox'}
   TransferBetweenListboxes;
   FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   ChooseFeaturesButton = findobj(figHandle, 'Tag', 'ChooseFeaturesButton');
   if ~isempty(get(FeaturesUseListbox, 'String'))
      set(ChooseFeaturesButton, 'Value', 1);
   else
      set(ChooseFeaturesButton, 'Value', 0);
   end
   CalcFeaturesButton = findobj(figHandle, 'Tag', 'CalculateFeaturesButton');
   set(CalcFeaturesButton, 'Value', 0);   
   
case 'CalculateFeaturesButton'
   % get channel validity
   for iCh = 1:4
      TTValidityButton = findobj(figHandle, 'Tag', ['TTValidity' num2str(iCh)]);
      MClust_ChannelValidity(iCh) = get(TTValidityButton, 'Value');
   end
   FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   FeaturesToUse = get(FeaturesUseListbox, 'String');
   MClust_FeatureData = [];
   MClust_FeatureNames = {};
   setptr(gcf, 'watch');
   nFeatures = length(FeaturesToUse);
   for iF = 1:nFeatures
      fprintf(2, 'Calculating feature: %s ... ', FeaturesToUse{iF});
      [nextFeatureData, nextFeatureNames] = ...
         feval(['feature_', FeaturesToUse{iF}], MClust_TTData, MClust_ChannelValidity);
      MClust_FeatureData = [MClust_FeatureData nextFeatureData];
      MClust_FeatureNames = [MClust_FeatureNames; nextFeatureNames];
      fprintf(2, 'done.\n'); 
   end
   setptr(gcf, 'arrow');
   set(cboHandle, 'Value', 1);
   
case 'ViewClusters'
   ViewClusters;
   
case 'CutWithConvexHulls'
   global MClust_FeatureData
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      GeneralizedCutter(MClust_Clusters, MClust_FeatureData, MClust_FeatureNames, 'mcconvexhull');
   end
      
case 'LoadCut'
   global MClust_Clusters
   fn = uigetfile('*.cut');
   if fn
      MClust_Clusters = LoadPreCut(fn);
   end
   
case 'SaveClusters'
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   switch computer
   case 'SOL2', [fn,dn] = uiputfile([basefn '.clusters']);
   case 'PCWIN', [fn,dn] = uiputfile(fullfile(basedn, [basefn '.clusters']));
   end
   if fn
      featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      featuresToUse = get(featureToUseHandle, 'String');
      
      save(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames', ...
         'MClust_ChannelValidity','featuresToUse','-mat');
      msgbox('Clusters saved successfully.', 'MClust msg');
   end
   
case 'LoadClusters'
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   [fn,dn] = uigetfile(fullfile(basedn, '*.clusters'));
   currentFeatureNames = MClust_FeatureNames;
   if fn
      load(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames', '-mat');
      if length(MClust_FeatureNames) ~= length(currentFeatureNames) | ~all(strcmp(currentFeatureNames, MClust_FeatureNames))
         errordlg({'Feature name mismatch!', 'Loaded clusters may be invalid.'}, 'MClust load error', 'modal');
      else
         msgbox('Clusters loaded successfully.', 'MClust msg');
      end
   end
    
case 'ClearClusters'
   ynClose = questdlg('Clearing clusters.  No undo available. Are you sure?', 'ClearQuestion', 'Yes', 'Cancel', 'Cancel');
   if strcmp(ynClose,'Yes')
      MClust_Clusters = {};
   end
  
case 'SaveDefaults'
   global MClust_Colors MClust_ChannelValidity
   [fn,dn] = uiputfile('defaults.mclust');
   if fn     
      featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      featuresToUse = get(featureToUseHandle, 'String');
      filetypeHandle = findobj(figHandle, 'Tag', 'InputType');
      MClust_FileType = get(filetypeHandle, 'value');
      save(fullfile(dn,fn), 'MClust_Colors', 'featuresToUse', 'MClust_ChannelValidity', 'MClust_FileType', '-mat');
      msgbox('Defaults saved successfully.', 'MClust msg');
   end
   
case 'LoadDefaults'
   global MClust_Colors MClust_ChannelValidity
   MClust_FileType = [];
   [fn,dn] = uigetfile('*.mclust');
   if fn
      load(fullfile(dn, fn), '-mat');
      
   % file type
   if ~isempty(MClust_FileType)
      filetypeHandle = findobj(figHandle, 'Tag', 'InputType');
      set(filetypeHandle, 'value', MClust_FileType);
   end
   
   % fix features to use boxen
   uifeaturesIgnoreHandle = findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox');
   uifeaturesUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   uiChooseFeaturesButton = findobj(figHandle, 'Tag', 'ChooseFeatures');
   allFeatures = [get(uifeaturesIgnoreHandle, 'String'); get(uifeaturesUseHandle, 'String')];
   featureIgnoreString = {};
   featureUseString = {};
   for iF = 1:length(allFeatures)
      if any(strcmp(allFeatures{iF}, featuresToUse))
         featureUseString = cat(1, featureUseString, allFeatures(iF));
      else
         featureIgnoreString = cat(1, featureIgnoreString, allFeatures(iF));
      end
   end
   set(uifeaturesIgnoreHandle, 'String', featureIgnoreString);
   set(uifeaturesUseHandle, 'String', featureUseString);
   if ~isempty(featureUseString)
      set(uiChooseFeaturesButton, 'Value', 1);
   end
   
   % fix channel validity 
   uich1 = findobj(figHandle, 'Tag', 'TTValidity1');
   uich2 = findobj(figHandle, 'Tag', 'TTValidity2');
   uich3 = findobj(figHandle, 'Tag', 'TTValidity3');
   uich4 = findobj(figHandle, 'Tag', 'TTValidity4');
   switch get(cboHandle, 'value') 
   case {1,2} % TT 
      set(uich1, 'value', 1, 'enable', 'on');
      set(uich2, 'value', 1, 'enable', 'on');
      set(uich3, 'value', 1, 'enable', 'on');
      set(uich4, 'value', 1, 'enable', 'on');
   case 3 % ST
      set(uich1, 'value', 1, 'enable', 'on');
      set(uich2, 'value', 1, 'enable', 'on');
      set(uich3, 'value', 0, 'enable', 'off');
      set(uich4, 'value', 0, 'enable', 'off');
   case 4 % SE
      set(uich1, 'value', 1, 'enable', 'on');
      set(uich2, 'value', 0, 'enable', 'off');
      set(uich3, 'value', 0, 'enable', 'off');
      set(uich4, 'value', 0, 'enable', 'off');
   otherwise
      error('Internal error: Unknown Input type');
   end
   
   set(uich1, 'Value', MClust_ChannelValidity(1));
   set(uich2, 'Value', MClust_ChannelValidity(2));
   set(uich3, 'Value', MClust_ChannelValidity(3));
   set(uich4, 'Value', MClust_ChannelValidity(4));
end
   
case 'WriteFiles'
   clusterIndex = ProcessClusters(MClust_FeatureData, MClust_Clusters);
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   featuresToUse = get(featureToUseHandle, 'String');
   save([fullfile(basedn, basefn), '.clusters'], 'MClust_Clusters', ...
      'MClust_FeatureNames', 'MClust_ChannelValidity', 'featuresToUse', '-mat');
   WriteClusterIndexFile([fullfile(basedn, basefn), '.cut'], clusterIndex);
   WriteTFiles(fullfile(basedn, basefn), MClust_TTData, MClust_FeatureData, MClust_Clusters);
   
   %RMB
    cut2clustern([fullfile(basedn,basefn), '.cut'], [fullfile(basedn,basefn), '.lv']);
   
   %msgbox('Files written.', 'MClust msg');
   
case 'About'
  helpwin MClust
   
case 'ExitButton'
   % check if ok
   ynClose = questdlg('Exiting MClust.  Are you sure?', 'ExitQuestion', 'Yes', 'Cancel', 'Cancel');
   if strcmp(ynClose,'Yes')
      close(figHandle);
   end
   
otherwise
   warndlg('Sorry, feature not yet implemented.');  
end % switch