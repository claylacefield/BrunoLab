function SplitTT(TTfname, CLfname, OSCategory)
% SplitTT(TTfname, CLfname, OSCategory)
%
% Creates new TT files from a given TT file and a coresponding .clusters file.
% INPUT:
%      TTfname  ... Cheetah TT filename (string)
%      CLfname  ... MClust .cluster file name (string)
%      Input category: SunTT, ntTT, ntST, ntSE
%
% ADR 1999, modified from code by Peter Lipa
% Version: 1.0 (Jan.2000)
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

if nargin == 0
   % choose category
   OSCategory = listdlg('ListString', {'Sun TT', 'nt TT', 'nt ST', 'nt SE'}, ...
      'SelectionMode', 'single', 'Name', 'Select input type', 'ListSize', [100,100]);
   if isempty(OSCategory)
      return;
   end  
      
   % find TTfname
   switch OSCategory
   case 1 % TT sun
      OSCategory = 'Sun TT';
      expExtension = '*.tt';
   case 4 % SE nt
      OSCategory = 'nt SE';
      expExtension = 'SE*.dat';
   case 3 % ST nt
      OSCategory = 'nt ST';
      expExtension = 'ST*.dat';
   case 2 % TT nt
      OSCategory = 'nt TT';
      expExtension = 'TT*.dat';
   otherwise
      error('Internal error: Unknown input file type.');
   end
   [TTfname, TTdn] = uigetfile(expExtension, 'TT file');  
   if ~TTfname, 
      return; 
   end
   pushdir(TTdn);
   
   % find CLname
   CLfname = uigetfile('*.clusters', 'CL file');
   if ~CLfname, 
      popdir; 
      return; 
   end
   
elseif nargin < 3
   error('Call with no arguments or with 3.');
end

% choose category
switch lower(OSCategory)
case {'suntt', 'sun tt'},
   SplitTTsun(TTfname, CLfname);
case {'nttt', 'nt tt'},
   SplitTTnt(TTfname, CLfname, 4);
case {'ntst', 'nt st'},
   SplitTTnt(TTfname, CLfname, 2);
case {'ntse', 'nt se'},
   SplitTTnt(TTfname, CLfname, 1);
end

popdir;