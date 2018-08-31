function H = ParentFigureHandle(objHandle)

% H = ParentFigureHandle(objHandle)
%
% INPUTS
%    objHandle - valid object handle
% 
% OUTPUTS
%    H - figure handle containing object or root if no figure found
%
% ADR 1998
% version L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

H = objHandle;
while ~strcmp(get(H, 'Type'),'figure') & ~strcmp(get(H, 'Type'),'root')
   H = get(H, 'Parent');
end