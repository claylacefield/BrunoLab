function DisplayProgress(iCounter, maxCounter, varargin)

% DisplayProgress(iCounter, maxCounter, varargin)
% DisplayProgress close
%
% INPUTS
%     iCounter = progress so far
%     maxCounter = when to stop
% 
% PARAMETERS
%   UseGraphics (default true): if true shows bar on screen else prints to stderr
%   Title (default 'Progress so far'): title for waitbar if used
%   EOL (default 80): end of line
%
% ADR 1998
% version L5.2
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

% close handle
if ischar(iCounter) & strcmp(iCounter, 'close')
   global DisplayProgressHandle
   close(DisplayProgressHandle);
   clear global DisplayProgressHandle
   return
end

if maxCounter == 1; return; end

%-------------------
% parameters

UseGraphics = 1;
Title = 'Progress so far';

EOL = 80;
SoFar = 10;

Extract_varargin;

%--------------------
if UseGraphics
   global DisplayProgressHandle
   if isempty(DisplayProgressHandle)
      DisplayProgressHandle = waitbar(0, Title);
   else
      waitbar(iCounter/maxCounter);
   end
   if iCounter == maxCounter
      close(DisplayProgressHandle);
      clear global DisplayProgressHandle
   end
   drawnow;
else
   if iCounter == 1
      fprintf(2, [Title ': .']);  
   elseif iCounter == maxCounter
      fprintf(2, '\n');
   elseif rem(iCounter,EOL) == 0
      fprintf(2, '\n');
   elseif rem(iCounter,10) == 0
      fprintf(2, '!');
   else
      fprintf(2, '.');
   end
end

