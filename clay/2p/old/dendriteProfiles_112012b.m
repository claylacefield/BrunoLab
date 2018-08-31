function [roiStruc] = dendriteProfiles


% ROI analysis for dendrites
%
% make structure with tree of:
%   a.) different dendrites
%   b.) different brances of same dendrite
%
% like: session.dendrite.branch.roiAvg

%%
% import TXT file with profiles for a number of ROIs
% (from ImageJ ROI Manager MultiMeasure)

s = uiimport;
data = s.data;
clear s;

numFrames = 1000;  % number of frames

numROIs = (size(data,1))/numFrames; % use numFrames to find numROIs in data

figure; hold on;

%%
% extract ROI mean pixel values from all frames and calculate dF/F
for i=1:numROIs
    roiMeans = data(i:numROIs:size(data,1),3); % extract ROI means
    roiMeanAv = mean(roiMeans); % take means over all frames
    roiDf = (roiMeans-roiMeanAv)/roiMeanAv; % calculate dF/F for this ROI
    
    % and save all to structure
    roiStruc(i).roiMeans = roiMeans;
    roiStruc(i).roiMeanAv = roiMeanAv;
    roiStruc(i).roiDf = roiDf;
    
    plot(2*roiDf+i);
end



d3b13 = xcorr(d3b1b, d3b3b, 10);