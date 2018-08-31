function mkContours(axesFrom, varargin)
% make contour plot
% 
% Original code by Peter Lipa 1999
%
% Modified by ADR 2000
%
% INPUTS
%   axesFrom = axis handle from which to draw the scatter points
% 
% parameters
%   nX = 100
%   nY = 100
%   figHandle = figure to draw in (def = new fig)
%   
%
% Draws a contour plot from scatter plot
%
% ADR 2000
% MClust 2.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m


nX = 100;
nY = 100;
figHandle = [];
Extract_varargin;

% -- get axis
fhaxes = findobj(axesFrom, 'Type', 'Axes');

%--- get some axis properties
XLim = get(fhaxes,'XLim');
YLim = get(fhaxes,'YLim');
AxLabels{1} = get(get(fhaxes,'XLabel'),'String');
AxLabels{2} = get(get(fhaxes,'YLabel'),'String');

%--- find figure handles to cluster line objects (identified by linestyle = none)
fhc = findobj(fhaxes, 'Type', 'Line'); 
%--- get and merge XData and YData
XData = [];
YData = [];
for ic = 1:length(fhc);
   Xc = get(fhc(ic),'XData');
   Yc = get(fhc(ic),'YData');
   if length(Xc) > 1
      XData = [XData Xc];
      YData = [YData Yc];
   end%if
end%for ic

if isempty(XData) 
  return
end

%--- finally make the histogram
H = ndhist([XData; YData], [nX; nY], [XLim(1); YLim(1)], [XLim(2); YLim(2)])';

[S,bb] = Hsmooth(H);
lS = fixedLog(S,-1);

if isempty(figHandle)
   figure;
end
[nX, nY] = size(lS);
X = linspace(XLim(1),XLim(2),nX);
Y = linspace(YLim(1),YLim(2),nY);
figure(figHandle);
Cont = contourf(X, Y , lS, 15);
xlabel(AxLabels{1}); ylabel(AxLabels{2});
zoom on;
%% colorbar;

%==========================================================
function fL = fixedLog(H, infimum)

%  returns the log(H) with H a N-dim array 
%  where the NaNs of log(x<=0) of H are replaced by infimum
%

fL = H;
negs = find(fL <0); 
fL(negs) = 0;
warning off;
fL = log(fL);
warning on;

nans = find(fL <= infimum);
fL(nans) = infimum;

return;


%==========================================
function [S, bb] = Hsmooth(H)
%
%  [S, bb] = Hsmooth(H)
%
% smoothes a 2D histogram H (= 2D array)
% with a 6-th order double low pass firls bb (linear phase least-square FIR filter)
%

% create filter
b = firls(6, [0 .5 .5 1], [1 .5 .5 0]);  
bb = kron(b',b);    % 2D filter = tensor product of 1D filters

S = filter2(bb,H);  % first pass (introduces a linear phase shift)
S = filter2(bb',S);  % second pass (compensates phase shift)