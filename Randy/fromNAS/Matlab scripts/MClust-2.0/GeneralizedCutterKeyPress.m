function GeneralizedCutterKeyPress()

% GeneralizedCutterKeyPress
%
% Callbacks for cut using convex hulls window
%
% ADR 1998
% version M1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


%---------------------------
% get startup info
figHandle = get(0, 'PointerWindow');
cutterFigHandle = findobj('Type', 'figure', 'Tag', 'ClusterCutWindow');  


switch get(figHandle, 'CurrentCharacter')
   
case 'r'
   cboHandle = findobj(cutterFigHandle, 'Tag', 'RedrawAxes');
   set(cboHandle, 'Value', ~get(cboHandle, 'Value'));
   GeneralizedCutterCallbacks(cboHandle);
   
case 'n'
   GeneralizedCutterCallbacks(findobj(cutterFigHandle, 'Tag', 'NextAxis'));
   
case 'p'
   GeneralizedCutterCallbacks(findobj(cutterFigHandle, 'Tag', 'PrevAxis'));
   
case 'u'
   GeneralizedCutterCallbacks(findobj(cutterFigHandle, 'Tag', 'Undo'));
   
case 'v'
   cboHandle = findobj(cutterFigHandle, 'Tag', 'ViewAllDimensions');
   set(cboHandle, 'Value', ~get(cboHandle, 'Value'));
   GeneralizedCutterCallbacks(cboHandle);
   
case 'c'
   cboHandle = findobj(cutterFigHandle, 'Tag', 'ContourPlot');
   GeneralizedCutterCallbacks(cboHandle);
   
case 'a'
   % if only one cluster is active...
   global MClust_Hide
   if sum(~MClust_Hide) == 1
      activeClust = find(MClust_Hide == 0)-1;
      if activeClust > 0
         cboHandle = findobj(cutterFigHandle, 'Tag', 'ClusterFunctions', 'UserData', activeClust);
         set(cboHandle, 'Value', 2);
         GeneralizedCutterCallbacks(cboHandle);
      end
   end
   
case 'd'
   % if only one cluster is active...
   global MClust_Hide
   if sum(~MClust_Hide) == 1
      activeClust = find(MClust_Hide == 0)-1;
      if activeClust > 0
         cboHandle = findobj(cutterFigHandle, 'Tag', 'ClusterFunctions', 'UserData', activeClust);
         set(cboHandle, 'Value', 3);
         GeneralizedCutterCallbacks(cboHandle);
      end
   end

end
