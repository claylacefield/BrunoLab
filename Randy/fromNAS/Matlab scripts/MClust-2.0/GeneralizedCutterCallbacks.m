function GeneralizedCutterCallbacks(cboHandle)

% GeneralizedCutterCallbacks
%
% Callbacks for cut using convex hulls window
%
% ADR 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

%---------------------------
% get startup info
if nargin == 0
   cboHandle = gcbo;
end
figHandle = ParentFigureHandle(cboHandle);  % control window figure handle
redrawAxesHandle = findobj(figHandle, 'Tag', 'RedrawAxes');
redrawAxesFlag = get(redrawAxesHandle, 'Value');
   
% global variables
global MClust_Clusters

%---------------------------
% main switch

switch get(cboHandle, 'Tag')
   
case 'ClusterCutWindow'    
   RedrawClusterKeys(cboHandle, 0);
   
case {'xdim', 'ydim', 'RedrawAxes', 'PlotMarker', 'PlotMarkerSize'}
   if redrawAxesFlag
      RedrawAxes(figHandle, 'full', 1);
   end
   
case 'PrevAxis'
   xdimHandle = findobj(figHandle, 'Tag', 'xdim');
   xdim = get(xdimHandle, 'Value');
   nxdim = length(get(xdimHandle, 'String'));
   ydimHandle = findobj(figHandle, 'Tag', 'ydim');
   ydim = get(ydimHandle, 'Value');
   nydim = length(get(ydimHandle, 'String'));
   if ydim > xdim+1
      set(ydimHandle, 'Value', ydim-1);
   else
      if xdim > 1
         set(xdimHandle, 'Value', xdim-1);
      else 
         set(xdimHandle, 'Value', nxdim-1);
      end
      set(ydimHandle, 'Value', nydim);
   end
   if redrawAxesFlag
      RedrawAxes(figHandle, 'full', 1);
   end
   
case 'NextAxis'
   xdimHandle = findobj(figHandle, 'Tag', 'xdim');
   xdim = get(xdimHandle, 'Value');
   nxdim = length(get(xdimHandle, 'String'));
   ydimHandle = findobj(figHandle, 'Tag', 'ydim');
   ydim = get(ydimHandle, 'Value');
   nydim = length(get(ydimHandle, 'String'));
   if ydim == nydim
      if xdim < nxdim-1
         set(xdimHandle, 'Value', xdim+1);
      else 
         set(xdimHandle, 'Value', 1);
      end
      set(ydimHandle, 'Value', get(xdimHandle, 'Value') + 1);
   else
      set(ydimHandle, 'Value', ydim+1);
   end
   if redrawAxesFlag
      RedrawAxes(figHandle, 'full', 1);
   end
   
case 'ContourPlot'
   contourWindow = findobj('Type', 'figure', 'Tag', 'ContourWindow');
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'CHDrawingAxisWindow');
   if isempty(contourWindow)
      contourWindow = figure('NumberTitle', 'off', 'Name', 'Contour Plot', 'Tag', 'ContourWindow');
   end
   mkContours(drawingFigHandle, 'figHandle', contourWindow);
   
case 'HideCluster'
   global MClust_Hide
   iClust = get(cboHandle, 'UserData');
   MClust_Hide(iClust + 1) = get(cboHandle, 'Value');
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'HideAll'
   global MClust_Hide
   MClust_Hide = ones(size(MClust_Hide));
   hideObjects = findobj(figHandle, 'Style', 'checkbox', 'Tag', 'HideCluster');
   set(hideObjects, 'Value', 1);
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'ShowAll'
   global MClust_Hide
   MClust_Hide = zeros(size(MClust_Hide));
   hideObjects = findobj(figHandle, 'Style', 'checkbox', 'Tag', 'HideCluster');
   set(hideObjects, 'Value', 0);
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'ViewAllDimensions'
   xdimHandle = findobj(figHandle, 'Tag', 'xdim');
   ydimHandle = findobj(figHandle, 'Tag', 'ydim');
   xnD = length(get(xdimHandle, 'String'));
   ynD = length(get(ydimHandle, 'String'));
   xsD = get(xdimHandle, 'Value');
   ysD = get(ydimHandle, 'Value');
   for iD = xsD:xnD
      for jD = max((iD+1),ysD):ynD   
         if get(cboHandle, 'Value')
            set(xdimHandle, 'Value', iD);
            set(ydimHandle, 'Value', jD);
            RedrawAxes(figHandle, 'full', 1);
            drawnow
         end
      end
   end
   RedrawAxes(figHandle);
   set(cboHandle, 'Value', 0);
   
case 'AxLimDlg'
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'CHDrawingAxisWindow');  % figure to draw in
   if ~isempty(drawingFigHandle)
      figure(drawingFigHandle);
      axlimdlg;
   end
   
case 'Add Cluster'
   StoreUndo('Add Cluster');
   global MClust_Clusters
   dY = 0.05;
   YLocs = 0.9:-dY:0.1;
   clusterType = get(cboHandle, 'UserData');
   
   if isempty(MClust_Clusters)
      MClust_Clusters = {feval(clusterType)};
   else
      MClust_Clusters{end+1} = feval(clusterType);
   end
   ClearClusterKeys(figHandle);
   RedrawClusterKeys(figHandle);
   
case 'Pack Clusters'
   StoreUndo('Pack Clusters');
   global MClust_Clusters MClust_FeatureData
   newClusterList = {};
   ClearClusterKeys(figHandle);
   for iC = 1:length(MClust_Clusters)
      if ~isempty(FindInCluster(MClust_Clusters{iC}, MClust_FeatureData))
         newClusterList{end+1} = MClust_Clusters{iC};     
      end
   end
   MClust_Clusters = newClusterList;
   RedrawClusterKeys(figHandle);
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'Undo'
   ClearClusterKeys(figHandle);
   RecallUndo;
   RedrawClusterKeys(figHandle);
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'CheckClusters'
   global MClust_TTData MClust_Clusters MClust_FeatureData MClust_TTfn
   [curdn,curfn] = fileparts(MClust_TTfn);
   for iClust = 1:length(MClust_Clusters)      
      clustTT = ExtractCluster(MClust_TTData, FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData));
      CheckCluster([curfn, ' -- Cluster ', num2str(iClust)], clustTT, StartTime(MClust_TTData), EndTime(MClust_TTData));
   end
   
case 'EvalOverlap'
   global MClust_Clusters MClust_FeatureData
   [nS, nD] = size(MClust_FeatureData);
   nClust = length(MClust_Clusters);
   nToDo = nClust * (nClust-1)/2;
   iDone = 0;
   overlap = zeros(nClust);
   for iC = 1:nClust
      iSpikes = zeros(nS, 1);
      fI = FindInCluster(MClust_Clusters{iC}, MClust_FeatureData);
      iSpikes(fI) = 1;
      for jC = (iC+1):nClust
         iDone = iDone +1;
         DisplayProgress(iDone, nToDo, 'Title', 'Evaluating overlap');
         jSpikes = zeros(nS, 1);
         fJ = FindInCluster(MClust_Clusters{jC}, MClust_FeatureData);
         jSpikes(fJ) = 1;
         overlap(iC,jC) = sum(iSpikes & jSpikes);
         overlap(jC,iC) = overlap(iC,jC);
      end
   end
   overlap = [(0:nClust)', [1:nClust; overlap]]
   msgbox(num2str(overlap), 'Overlap');

case 'Autosave'
   Autosave(1);

case 'Exit'
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'CHDrawingAxisWindow');  % figure to draw in
   if ~isempty(drawingFigHandle)
      close(drawingFigHandle)
   end
   contourFigHandle = findobj('Type', 'figure', 'Tag', 'ContourWindow'); % contour plot window
   if ~isempty(contourFigHandle)
      close(contourFigHandle)
   end
   close(figHandle)
   
case 'ChooseColor'
   global MClust_Colors    
   iClust = get(cboHandle, 'UserData')+1;
   MClust_Colors(iClust,:) = uisetcolor(MClust_Colors(iClust,:), 'Set Cluster Color');
   set(cboHandle, 'BackgroundColor', MClust_Colors(iClust,:));
   lineHandle = findobj('Tag', 'ClusterLine', 'UserData', iClust);
   if ~isempty(lineHandle)
      set(lineHandle, 'Color', MClust_Colors(iClust, :));
   elseif redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'ScrollClusters'
   ClearClusterKeys(figHandle);
   RedrawClusterKeys(figHandle);
   
case 'UnaccountedForOnly'
   global MClust_UnaccountedForOnly
   MClust_UnaccountedForOnly = get(cboHandle, 'Value');
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end   
   
case 'ClusterFunctions'
   cboString = get(cboHandle, 'String');
   cboValue = get(cboHandle, 'Value');
   if cboValue == 1; return; end   
   set(cboHandle, 'Value', 1);
   switch cboString{cboValue}
      
   case 'Add limit'
      StoreUndo('Add limit');
      iClust = get(cboHandle, 'UserData');
      
      XdimHandle = findobj(figHandle, 'Tag', 'xdim'); % get x dimension
      xdim = get(XdimHandle, 'Value');
      
      YdimHandle = findobj(figHandle, 'Tag', 'ydim'); % get y dimension
      ydim = get(YdimHandle, 'Value');   
      
      drawingFigHandle = findobj('Type', 'figure', 'Tag', 'CHDrawingAxisWindow');  % figure to draw in
      if isempty(drawingFigHandle)
         errordlg('No drawing axis available.', 'Error');
      else
         drawingAxisHandle = findobj(drawingFigHandle, 'Type', 'axes');
         MClust_Clusters{iClust} = AddLimit(MClust_Clusters{iClust}, xdim, ydim, drawingAxisHandle);
      end
      if redrawAxesFlag  
         RedrawAxes(figHandle);
      end
      
   case 'Delete limit'
      StoreUndo('Delete limit');
      
      iClust = get(cboHandle, 'UserData');
      
      XdimHandle = findobj(figHandle, 'Tag', 'xdim'); % get x dimension
      xdim = get(XdimHandle, 'Value');
      
      YdimHandle = findobj(figHandle, 'Tag', 'ydim'); % get y dimension
      ydim = get(YdimHandle, 'Value');   
      
      MClust_Clusters{iClust} = DeleteLimit(MClust_Clusters{iClust}, xdim, ydim);
      if redrawAxesFlag
         RedrawAxes(figHandle);
      end
      
   case 'Delete all limits'
      StoreUndo('Delete all limits');
      iClust = get(cboHandle, 'UserData');
      XdimHandle = findobj(figHandle, 'Tag', 'xdim'); % get x dimension
      maxXdim = length(get(XdimHandle, 'String'));
      YdimHandle = findobj(figHandle, 'tag', 'ydim'); % get y dimension
      maxYdim = length(get(YdimHandle, 'String'));
      for iX = 1:maxXdim
         for iY = 1:maxYdim
            MClust_Clusters{iClust} = DeleteLimit(MClust_Clusters{iClust}, iX, iY);
         end
      end
      if redrawAxesFlag
         RedrawAxes(figHandle);
      end
      
   case 'Copy cluster'
      StoreUndo('Copy cluster');
      global MClust_Clusters
      
      iClust = get(cboHandle, 'UserData');
      MClust_Clusters{end+1} = MClust_Clusters{iClust};
      iC = length(MClust_Clusters);
      ClearClusterKeys(figHandle);
      RedrawClusterKeys(figHandle);
      warndlg(['Cluster ' num2str(iClust) ' copied to cluster ' num2str(iC) '.'], 'Copy successful');
      
      
   case 'Merge with'
      StoreUndo('Merge');
      global MClust_Clusters
      iClust = get(cboHandle, 'UserData');
      mergeClust = inputdlg('Cluster to merge with?');
      mergeClust = str2num(mergeClust{1});
      if mergeClust > 0 & mergeClust <= length(MClust_Clusters) & mergeClust ~= iClust
         MClust_Clusters{end+1} = Merge(MClust_Clusters{iClust}, MClust_Clusters{mergeClust});
         ClearClusterKeys(figHandle);
         RedrawClusterKeys(figHandle);
         warndlg(['Cluster ' num2str(iClust) ' merged with cluster ' num2str(mergeClust) '.'], 'Merge successful');
      else
         errordlg(['Cannot merge clusters ' num2str(iClust) ' and ' num2str(mergeClust) '.']);
      end
      
   case 'Average waveform'
      global MClust_TTData MClust_Clusters MClust_FeatureData
      iClust = get(cboHandle, 'UserData');
      clustTT = ExtractCluster(MClust_TTData, FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData));
      figure; AverageWaveform(clustTT); 
      title(['Average Waveform: Cluster ' num2str(iClust)]);
      
   case 'Hist ISI'
      global MClust_TTData MClust_Clusters MClust_FeatureData
      iClust = get(cboHandle, 'UserData');
      clustTT = ExtractCluster(MClust_TTData, FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData));
      figure; HistISI(Range(clustTT, 'ts'));
      title(['ISI Histogram: Cluster ' num2str(iClust)]);
      
   case 'Check Cluster'
      global MClust_TTData MClust_Clusters MClust_FeatureData MClust_TTfn
      iClust = get(cboHandle, 'UserData');
      if iClust == 0
         clustTT = MClust_TTData;
      else
         clustTT = ExtractCluster(MClust_TTData, FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData));
      end
      [curdn,curfn] = fileparts(MClust_TTfn);
      CheckCluster([curfn, ' -- Cluster ', num2str(iClust)], clustTT, StartTime(MClust_TTData), EndTime(MClust_TTData));
        
   case 'Variances'
      global MClust_FeatureData MClust_Clusters
      xdimHandle = findobj(figHandle, 'Tag', 'xdim');
      xdimString = get(xdimHandle, 'String');
      iClust = get(cboHandle, 'UserData');
      f = FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData);
      if length(f) > 2
         variances = std(MClust_FeatureData(f,:), 1) ./ (max(MClust_FeatureData) - min(MClust_FeatureData));
         [dummy, order] = sort(variances);
         order = order(end:-1:1);
         msg = cell(length(variances),1);
         for iC = 1:length(variances)
            msg{iC} = sprintf('%10s --- %.5f', xdimString{order(iC)}, variances(order(iC)));
         end
         msgbox(msg, ['Var: Cluster ' num2str(iClust)]);
      else
         errordlg('Too few points to calculate variances.', 'MClust error', 'modal');
      end         
      
   case 'Show info'
      global MClust_Clusters
      iClust = get(cboHandle, 'UserData');
      msgbox(GetInfo(MClust_Clusters{iClust}), ['Cluster ', num2str(iClust)]);
      
   otherwise
      warndlg({'Function not yet available.', get(cboHandle, 'Tag')}, 'Implentation Warning');
      
   end
   
otherwise
   warndlg({'Feature not yet available.', get(cboHandle, 'Tag')}, 'Implentation Warning');
   
end % switch

%---------------------------
% subfunctions

function RedrawAxes(figHandle, varargin)

% -- get variables
full = 0;
Extract_varargin;

global MClust_Clusters MClust_Colors MClust_Hide MClust_UnaccountedForOnly
nClust = length(MClust_Clusters);

drawingFigHandle = findobj('Type', 'figure', 'Tag', 'CHDrawingAxisWindow');  % figure to draw in
data = get(figHandle, 'UserData');  % data to plot
xdimHandle = findobj(figHandle, 'Tag', 'xdim');
xdim = get(xdimHandle, 'Value');           % x dimemsion to plot
xlbls = get(xdimHandle, 'String');         % x labels
ydimHandle = findobj(figHandle, 'Tag', 'ydim');
ydim = get(ydimHandle, 'Value');           % y dimension to plot
ylbls = get(ydimHandle, 'String');         % y lables
markerHandle = findobj(figHandle, 'Tag', 'PlotMarker');
markerString = get(markerHandle, 'String');
markerValue = get(markerHandle, 'Value');
marker = markerString{markerValue};
markerSizeHandle = findobj(figHandle, 'Tag', 'PlotMarkerSize');
markerSizeString = get(markerSizeHandle, 'String');
markerSizeValue = get(markerSizeHandle, 'Value');
markerSize = str2num(markerSizeString{markerSizeValue});

if isempty(drawingFigHandle)
   % create new drawing figure
   drawingFigHandle = ...
      figure('Name', 'Cluster Cutting Window',...
      'NumberTitle', 'off', ...
      'Tag', 'CHDrawingAxisWindow', ...
      'KeyPressFcn', 'GeneralizedCutterKeyPress');
   whitebg('black'); % RMB
else
   % figure already exists -- select it
   figure(drawingFigHandle);
end

% have to a complete redraw
if ~full
   curAxis = axis;
end
clf;
hold on;
for iC = 0:nClust     
   if ~MClust_Hide(iC+1)
      HideClusterHandle = findobj(figHandle, 'UserData', iC, 'Tag', 'HideCluster');
      if iC == 0
         if MClust_UnaccountedForOnly
            clusterIndex = ProcessClusters(data, MClust_Clusters);
            f = find(clusterIndex == 0);
            figure(drawingFigHandle);
            h = plot(data(f,xdim), data(f,ydim), marker);
         else
            figure(drawingFigHandle);
            h = plot(data(:,xdim), data(:,ydim), marker);
         end
      else         
         [f,MCC] = FindInCluster(MClust_Clusters{iC}, data);
         if isempty(f) & ~isempty(HideClusterHandle)
            set(HideClusterHandle, 'Enable', 'off');
         else 
            set(HideClusterHandle, 'Enable', 'on');
         end
         figure(drawingFigHandle);
         h = plot(data(f,xdim), data(f,ydim), marker);
      end
      set(h, 'Color', MClust_Colors(iC+1,:));
      set(h, 'Tag', 'ClusterLine', 'UserData', iC);
      set(h, 'MarkerSize', markerSize);
      if iC > 0 & isa(MClust_Clusters{iC}, 'mcconvexhull')
         figure(drawingFigHandle);
         DrawOnAxis(MClust_Clusters{iC}, xdim, ydim, MClust_Colors(iC+1,:));        
      end   
   end
end
figure(drawingFigHandle);
if full
   set(gca, 'XLim', [min(data(:,xdim)) max(data(:, xdim))]);
   set(gca, 'YLim', [min(data(:,ydim)) max(data(:, ydim))]);
else
   axis(curAxis);
end
xlabel(xlbls{xdim});
ylabel(ylbls{ydim});
zoom on

contourWindow = findobj('Type', 'figure', 'Tag', 'ContourWindow');
if ~isempty(contourWindow)
   mkContours(drawingFigHandle, 'figHandle', contourWindow);
end
figure(drawingFigHandle);

%=========================================
function StoreUndo(funcname)
global MClust_Undo MClust_Clusters
MClust_Undo.clusters = MClust_Clusters;
MClust_Undo.funcname = funcname;
% count down autosave
Autosave;

function RecallUndo
global MClust_Undo MClust_Clusters
MClust_Clusters = MClust_Undo.clusters;
msgbox(['Undid function ', MClust_Undo.funcname], 'Undo', 'none', 'modal');
StoreUndo('Undo');

%========================================
function ClearClusterKeys(figHandle)
global MClust_Clusters
for iC = 0:length(MClust_Clusters)
   clusterKeys = findobj(figHandle, 'UserData', iC);
   for iK = 1:length(clusterKeys)
      delete(clusterKeys(iK))
   end
end

function RedrawClusterKeys(figHandle, startCluster)
global MClust_Clusters
if nargin == 1
   sliderHandle = findobj(figHandle, 'Tag', 'ScrollClusters');
   startCluster = floor(-get(sliderHandle, 'Value'));
end
endCluster = floor(min(startCluster + 15, length(MClust_Clusters)));
for iC = startCluster:endCluster
   CreateClusterKeys(figHandle, iC, 0.35, 0.9 - 0.05 * (iC - startCluster), 'GeneralizedCutterCallbacks', ...
      'Add limit', 'Delete limit', 'Delete all limits', 'Copy cluster', 'Merge with', 'Average waveform', 'Hist ISI', 'Check Cluster', 'Variances', 'Show info');
end

%========================================
function Autosave(force)

if nargin == 0; force = 0; end

global MClust_Autosave
MClust_Autosave = MClust_Autosave-1;
autosaveCounterHandle = findobj('Tag', 'Autosave');

if MClust_Autosave == 0 | force
   set(autosaveCounterHandle, 'String', 'Autosaving ...');
   % get components
   global MClust_Colors MClust_TTfn MClust_Clusters MClust_FeatureNames MClust_ChannelValidity
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   featureToUseHandle = findobj('Tag', 'FeaturesUseListbox');
   featuresToUse = get(featureToUseHandle, 'String');
   % save defaults
   save(fullfile(basedn,'autodflts.mclust'), 'MClust_Colors', 'featuresToUse', '-mat');
   % save clusters
   global MClust_Clusters
   save(fullfile(basedn,'autosave.clusters'), 'MClust_Clusters', 'MClust_FeatureNames', ...
      'MClust_ChannelValidity','featuresToUse','-mat');
   % reset counter
   global MClust_Autosave
   MClust_Autosave = 10;
   set(autosaveCounterHandle, 'String', 'Autosaved');
end

set(autosaveCounterHandle, 'String', ['Autosave in ' num2str(MClust_Autosave)]);