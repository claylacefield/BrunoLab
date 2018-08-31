function [frameAvgDf1, frameAvgDf2, caRefCorr, diffCorr] = impTifStack(numImCh, hz)

%% This is a script to import TIFF stacks of 2photon data
%  into the MATLAB workspace for analysis
%
%  clay041513
%
%  042113: added in import of 2 channels, and takes frame average 
%  of both Calcium and reflected IR and performs cross-correlation


[filename, pathname] = uigetfile('*.tif');
tifpath = [pathname filename];

disp(['Processing image stack for ' filename]);

% see how big the image stack is
stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack (all channels)
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

frameNum = 0;

for i=1:numImCh:sizeStack
    frame = imread(tifpath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack1(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
end

frameNum = 0;

if numImCh == 2
    for i=2:numImCh:sizeStack
        frame = imread(tifpath, 'tif', i); % open the TIF frame
        frameNum = frameNum + 1;
        tifStack2(:,:,frameNum)= frame;  % make into a TIF stack
        %imwrite(frame*10, 'outfile.tif')
    end
else
    tifStack2 = 0;
    caRefCorr = 0;
end


% tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)
% 

frameAvg1 = mean(mean(tifStack1,1),2);  % take average for each frame
frameAvg1 = squeeze(frameAvg1);  % just remove singleton dimensions
frameAvgDf1 = (frameAvg1 - mean(frameAvg1, 1))/mean(frameAvg1,1);    % just subtract mean

% % now doing this with the running mean (runmean from Matlab
% % Cntrl)
% 
% runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
% 
% frameAvgDf = (frameAvg - runAvg)./runAvg;

if numImCh ==2 
    frameAvg2 = mean(mean(tifStack2,1),2);  % take average for each frame
    frameAvg2 = squeeze(frameAvg2);
    frameAvgDf2 = (frameAvg2 - mean(frameAvg2, 1))/mean(frameAvg2,1);
    
    caRefCorr = xcorr(frameAvgDf1, frameAvgDf2, 20*hz);    % xcorr of Ca and reflected IR
    
    d1 = diff(frameAvgDf1);
    d2 = diff(frameAvgDf2);
    
    diffCorr = xcorr(d1,d2, 5*hz);    % now take xcorr of diff

end

% % figure; plot(frameAvgDf);