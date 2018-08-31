function [whiskSig] = whiskVideoProc()



% this script pre-processes whisker video to extract movement


% import the TXT file from previous FIJI whisker ROI selection

% whiskVidStruc = importdata(videoTxt);  % if you know the filename

whiskVidStruc = uiimport();

% this is just Max-Min pixel values for each frame (whiskerROI)
whiskSig = whiskVidStruc.data(:,4)- whiskVidStruc.data(:,3);

% and just normalize
whiskSig = (whiskSig-mean(whiskSig, 1))/mean(whiskSig, 1);

