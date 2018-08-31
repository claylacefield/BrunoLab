function DIRSTACK = pushdir(newdir);

% dirstack = pushdir(newdir)
%
% Pushes the current dir onto the directory stack.
% Then cd's to the newdir if given.
% Maintains the directory stack in a global variable.
%
% ADR 1998
% version L4.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

global DIRSTACK

if isempty(DIRSTACK)
   DIRSTACK = {pwd};
else
   DIRSTACK = [{pwd} DIRSTACK];
end

if nargin == 1
   cd(newdir);
end
