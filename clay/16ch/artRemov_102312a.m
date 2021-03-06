function [x3] = artRemov()


% code to eliminate movement artifact from 16ch data from behaving
% head-restrained animals

% OLD
% ideas of features that can be used to clip these epochs
% 1.) places where signal is too large (+/-)
% 2.) places where diff(x) is too large (start of artifact)
% 3.) places where diff(x) is too small for a stretch (during artifact)
%
% 102312
% Using LocalMinima to detect artifact peaks
% and clipping a little bit before and after

%% to load in specified file
% folder = '/home/clay/Documents/Data/083112/083112_mouseH24';
% 
% basename = '083112_mouseH24';
% 
% % try importing RAW file for a channel to test filtering, etc.
% ii = 5; % channel number to look at
% inFile=[folder filesep basename '.raw.' int2str(ii)];
% fi=fopen(inFile,'r','ieee-le');
% x=fread(fi,'float32','ieee-le');
% fclose(fi);

%% or choose with GUI
[filename pathname] = uigetfile('*.raw.3', 'Select a .dat file of whisker signals to read');
filepath = [pathname filename];

[fid, message] = fopen(filepath, 'r', 'l'); % 'le' for reardon-style data (;'be' for ntrode)
x = fread(fid,'*float32'); 
fclose(fid);

% then test filtering with normal functions from Reardon's script
% highpass=filtfilt(bbhigh,aahigh,x);
% filteredData=filtfilt(bblow,aalow,highpass);

% (seems highpass gives artifact at transitions)

% find indices
% badInd = find(abs(x)>0.1);

% find indices where signal gets really big (i.e. artifact)
% bigInd = find(abs(x)>1);


%% Find and zero area around peaks

x3 = x;     % just make a copy of the signal for clipping artifacts

% set a few variables
thresh = 1; % voltage threshold for local maximum detection
preClip = 1000;  % samples to clip before peak
postClip = 2000; % samples to clip after peak

% look for local maxima/minima

posPeaks = LocalMinima(-x, 2000, -1);   % this works pretty well

% then zero out the areas around the positive peaks
for n = 1:length(posPeaks); 
    startArt = posPeaks(n)-preClip; 
    endArt = posPeaks(n)+postClip; 
    x3(startArt:endArt)=0; 
end


negPeaks = LocalMinima(x, 2000, -thresh);

% then zero out the areas around the negative peaks
for n = 1:length(negPeaks); 
    startArt = negPeaks(n)-preClip; 
    endArt = negPeaks(n)+postClip; 
    x3(startArt:endArt)=0; 
end


%% Old ways I was experimenting with (not using LocalMinima)
% % (now find beginning and ending indices of artifacts)
% 
% % this should give the transitions between non-artifact and artifacts
% 
% diffBigInd = diff(bigInd);  
% 
% % now just adjust to same length as original
% 
% diffBigInd = [diffBigInd; 1];
% 
% % this finds ends of the artifacts
% transInd = find(diffBigInd > 1);
% endArtInd =  bigInd(transInd);
% 
% % and the beginnings are just the next index of values > 1
% % (but this will not get the beginning of the first artifact in a trace)
% beginArtInd =  bigInd(transInd+1);
% 
% % now chew back a little bit from the ends of each artifact
% endArtInd2 = endArtInd + 200; 
% beginArtInd2 = beginArtInd - 200;
% 
% 
% % 
% % beginArt = transInd(1:2:length(transInd));
% % 
% % endArt =  transInd(2:2:length(transInd));
% 
% % for i = 1:length(beginArt)
% %     x();
    






