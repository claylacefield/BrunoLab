function [roiStruc, roiAvgDf] = dendriteProfiles2(numFrames, avg, roi)


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

% changed 052314
% Saving ROIs in diff form, #fr x #rois
% thus changing how this is done

roiStruc = [];
roiAvgDf = [];

if roi == 1
    
    s = uiimport;
    imageJresults = s.data;
    clear s;
    
    %numFrames = 1000;  % number of frames (now taking this as argument)
    
    numROIs = (size(imageJresults,1))/numFrames; % use numFrames to find numROIs in data
    
    % figure; hold on;
    
    % extract ROI mean pixel values from all frames and calculate dF/F
    for i=1:numROIs
        roiMeans = imageJresults(i:numROIs:size(imageJresults,1),3); % extract ROI means
        roiMeanAv = mean(roiMeans); % take means over all frames
        roiDf = (roiMeans-roiMeanAv)/roiMeanAv; % calculate dF/F for this ROI
        
        % and save all to structure
        roiStruc(i).roiMeans = roiMeans;
        roiStruc(i).roiMeanAv = roiMeanAv;
        roiStruc(i).roiDf = roiDf;
        
        % plot(2*roiDf+i);
    end
    
    clear imageJresults;
    
end

%% And/or process imageJ whole frame averages

if avg == 1
    s = uiimport;
    imageJresults2 = s.data;
    clear s;
    
    frameAvg = imageJresults2(:,3);
    frameAvgAvg = mean(frameAvg); % take means over all frames
    roiAvgDf = (frameAvg-frameAvgAvg)/frameAvgAvg; % calculate dF/F for this ROI
    
    clear imageJresults2;
    
end

% d3b13 = xcorr(d3b1b, d3b3b, 10);