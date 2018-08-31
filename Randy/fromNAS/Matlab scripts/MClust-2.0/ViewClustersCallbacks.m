function ViewClustersCallbacks()

% ViewClustersCallbacks
%
% Callbacks for view clusters window
%
% ADR 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

%------------------------------------
% handles 
cboHandle = gcbo;
figHandle = ParentFigureHandle(cboHandle);
redrawAxesHandle = findobj(figHandle, 'Tag', 'RedrawAxes');
redrawAxesFlag = get(redrawAxesHandle, 'Value');

%--------------------------------------
% main switch
switch get(cboHandle, 'Tag')
   
case 'ViewClustersWindow'
   RedrawClusterKeys(cboHandle, 0);
   
case {'xdim', 'ydim', 'zdim', 'RedrawAxes'}
   if redrawAxesFlag
      RedrawAxes(figHandle)
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
      
case {'Rotate'}
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in
   if isempty(drawingFigHandle)
      RedrawAxes(figHandle)
   else
      figure(drawingFigHandle);
   end
   set(gca, 'CameraViewAngleMode', 'manual');
   [az, el] = view;
   while az<720 & get(cboHandle, 'Value') == 1
      figure(drawingFigHandle);
      az = az + 5;
      view(az, el);
      drawnow
   end
   
case 'AxLimDlg'
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in
   if ~isempty(drawingFigHandle)
      figure(drawingFigHandle);
      axlimdlg;
   end
   
case {'ViewAllDimensions'}
   global MClust_FeatureData MClust_FeatureNames
   nD = length(MClust_FeatureNames);
   VADHandle = figure('NumberTitle', 'off', 'Name', 'View all dimensions');        
   for iD = 1:nD
      for jD = (iD+1):nD   
         if get(cboHandle, 'Value')
            plot(MClust_FeatureData(:,iD), MClust_FeatureData(:,jD), '.');
            xlabel(MClust_FeatureNames{iD});
            ylabel(MClust_FeatureNames{jD});
            drawnow
            pause(1);
         end
      end
   end
   set(cboHandle, 'Value', 0);
   close(VADHandle)
   
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
   
   
case 'UpdateClusters'
   ClearClusterKeys(figHandle);
   RedrawClusterKeys(figHandle);
   
% CLUSTER KEYS

case 'ScrollClusters'
   global MClust_Clusters
   for iC = 0:length(MClust_Clusters)
      clusterKeys = findobj(figHandle, 'UserData', iC);
      for iK = 1:length(clusterKeys)
         delete(clusterKeys(iK))
      end
   end
   startCluster = floor(-get(cboHandle, 'Value'));
   endCluster = floor(min(startCluster + 15, length(MClust_Clusters)));
   for iC = startCluster:endCluster
      CreateClusterKeys(figHandle, iC, 0.4, 0.9 - 0.05 * (iC - startCluster), 'ViewClustersCallbacks', ...
               'Average waveform', 'Hist ISI', 'Autocorrelation', 'Spike width', 'Peak:Valley Ratio', 'Check cluster', 'Show info');

   end

case 'ChooseColor'
   global MClust_Colors    
   iClust = get(cboHandle, 'UserData')+1;
   MClust_Colors(iClust,:) = uisetcolor(MClust_Colors(iClust,:), 'Set Cluster Color');
   set(cboHandle, 'BackgroundColor', MClust_Colors(iClust,:));
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'HideCluster'
   global MClust_Hide
   iClust = get(cboHandle, 'UserData');
   MClust_Hide(iClust + 1) = get(cboHandle, 'Value');
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'UnaccountedForOnly'
   global MClust_UnaccountedForOnly
   MClust_UnaccountedForOnly = get(cboHandle, 'Value');
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end   
   
% FUNCTIONS
case 'ClusterFunctions'
   cboString = get(cboHandle, 'String');
   cboValue = get(cboHandle, 'Value');
   
   switch cboString{cboValue}      
      
   case 'Check cluster'
      global MClust_TTData MClust_Clusters MClust_FeatureData MClust_TTfn
      iClust = get(cboHandle, 'UserData');
      if iClust == 0
         clustTT = MClust_TTData;
      else
         clustTT = ExtractCluster(MClust_TTData, FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData));
      end
      [curdn,curfn] = fileparts(MClust_TTfn);
      CheckCluster([curfn, ' -- Cluster ', num2str(iClust)], clustTT, StartTime(MClust_TTData), EndTime(MClust_TTData));
      
   case 'Show info'
      global MClust_Clusters
      iClust = get(cboHandle, 'UserData');
      msgbox(GetInfo(MClust_Clusters{iClust}), ['Cluster ', num2str(iClust)]);    
      
   otherwise
      warndlg({'View Clusters is still under construction.',cboString{cboValue}, 'Function not yet implemented.'});
   
   end
   set(cboHandle, 'Value', 1);
      
% EXIT
case {'Exit'}
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in
   if ~isempty(drawingFigHandle)
      close(drawingFigHandle)
   end
   close(figHandle);

otherwise
   warndlg({'View Clusters is still under construction.',get(cboHandle, 'Tag'), 'Feature not yet implemented.'});
   
end % switch

%----------------------------------------
% SUBFUNCTION

%------------
% Redraw Axes
function RedrawAxes(figHandle)

% globals
global MClust_Clusters MClust_Colors MClust_FeatureData MClust_Hide MClust_UnaccountedForOnly

% get keys
xHandle = findobj(figHandle, 'Tag', 'xdim');
xDim = get(xHandle, 'Value');
xLabels = get(xHandle, 'String');
xFeatureName = xLabels(xDim);
yHandle = findobj(figHandle, 'Tag', 'ydim');
yDim = get(yHandle, 'Value');
yLabels = get(yHandle, 'String');
yFeatureName = yLabels(yDim);
zHandle = findobj(figHandle, 'Tag', 'zdim');
zDim = get(zHandle, 'Value');
zLabels = get(zHandle, 'String');
zFeatureName = zLabels(zDim);

% find drawing figure
drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in

if isempty(drawingFigHandle)
   % create new drawing figure
   drawingFigHandle = figure('Name', 'Clusters: 3d plot',...
   'NumberTitle', 'off', ...
   'Tag', 'VCDrawingAxisWindow');
	view(3); [az,el] = view;
else
   % figure already exists -- select it
   figure(drawingFigHandle);
   [az,el] = view;
end

clf;
hold on;
nClust = length(MClust_Clusters);

for iC = 0:nClust  
   HideClusterHandle = findobj(figHandle, 'Tag', 'HideCluster', 'UserData', iC);
   if ~MClust_Hide(iC+1)
      if iC == 0
         if MClust_UnaccountedForOnly
            clusterIndex = ProcessClusters(MClust_FeatureData, MClust_Clusters);
            f = find(clusterIndex == 0);
            h = plot3(MClust_FeatureData(f,xDim), MClust_FeatureData(f,yDim), MClust_FeatureData(f,zDim), '.');
         else
            h = plot3(MClust_FeatureData(:,xDim), MClust_FeatureData(:,yDim), MClust_FeatureData(:,zDim), '.');
         end
      else         
         [f, MCC] = FindInCluster(MClust_Clusters{iC}, MClust_FeatureData);
         if isempty(f) & ~isempty(HideClusterHandle)
            set(HideClusterHandle, 'Enable', 'off');
         else 
            set(HideClusterHandle, 'Enable', 'on');
         end
         h = plot3(MClust_FeatureData(f,xDim), MClust_FeatureData(f,yDim), MClust_FeatureData(f,zDim), '.');
      end
      set(h, 'Color', MClust_Colors(iC+1,:));
      set(h, 'MarkerSize', 1);

   end
end
set(gca, 'XLim', [min(MClust_FeatureData(:,xDim)) max(MClust_FeatureData(:, xDim))]);
set(gca, 'YLim', [min(MClust_FeatureData(:,yDim)) max(MClust_FeatureData(:, yDim))]);
set(gca, 'ZLim', [min(MClust_FeatureData(:,zDim)) max(MClust_FeatureData(:, zDim))]);
xlabel(xFeatureName);
ylabel(yFeatureName);
zlabel(zFeatureName);
view(az,el);
rotate3d on;

%=========================
function ClearClusterKeys(figHandle)
global MClust_Clusters
for iC = 0:100
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
   CreateClusterKeys(figHandle, iC, 0.4, 0.9 - 0.05 * (iC - startCluster), 'ViewClustersCallbacks', ...
      'Check cluster', 'Show info');
end
