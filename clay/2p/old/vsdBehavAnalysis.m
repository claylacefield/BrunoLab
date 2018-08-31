
function [correctRespStruc, framesStack, vsdRespStruc] = vsdBehavAnalysis()

% This script is to analyze linescan data based upon behavioral
% performance recorded on Processing from the Arduino
% USAGE:
% [correctRespStruc] = vsdBehavAnalysis();


frameNum = 0;

% use UI to pick TIFF stack to analyze
if nargin < 1
    [filename pathname] = uigetfile('*.tif', 'Select a multi-page TIFF to read');
    filepath = [pathname filename];
end

% see how big the image stack is
stackInfo = imfinfo(filepath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;

tifStack = zeros(height, width, sizeStack, 'uint16'); % must specify "int" or runs out of memory

%%
% load in the TIFF stack
for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;
    %imwrite(frame, 'outfile.tif')
end

% NOTE: this loop takes a long time to process- think of alternative

% use UI to pick TXT behavioral data file and analyze
[correctRespStruc] = correctResp2p();

stimType = correctRespStruc.stimTypeArr;
corrRespArr = correctRespStruc.corrRespArr;

% find indices of diff trial types
rewStimInd = find(stimType == 1);
unrewStimInd = find(stimType == 2);

% correct resp
typeXresp = stimType.*corrRespArr;
corrRewInd = find(typeXresp == 1);
corrUnrewInd = find(typeXresp == 2);

% incorr resp
typeXincorr = stimType-typeXresp;
incorrRewInd = find(typeXincorr == 1); 
incorrUnrewInd = find(typeXincorr == 2);

% make substacks of frames from particular trial types
rewStimFrames = tifStack(:,:,rewStimInd);
unrewStimFrames = tifStack(:,:,unrewStimInd);
corrRewFrames = tifStack(:,:,corrRewInd);
corrUnrewFrames = tifStack(:,:,corrUnrewInd);
incorrRewFrames = tifStack(:,:,incorrRewInd);
incorrUnrewFrames = tifStack(:,:,incorrUnrewInd);

% find mean VSD responses for these trial types
avRewStimFrame = mean(rewStimFrames, 3);
avUnrewStimFrame = mean(unrewStimFrames, 3);

avCorrRewFrame = mean(corrRewFrames, 3);
avCorrUnrewFrame = mean(corrUnrewFrames, 3);
avIncorrRewFrame = mean(incorrRewFrames, 3);
avIncorrUnrewFrame = mean(incorrUnrewFrames, 3);

% and average over entire spatial range
avRewStimPlot = mean(avRewStimFrame, 2);
avUnrewStimPlot = mean(avUnrewStimFrame, 2);

avCorrRewPlot = mean(avCorrRewFrame, 2);
avCorrUnrewPlot = mean(avCorrUnrewFrame, 2);
avIncorrRewPlot = mean(avIncorrRewFrame, 2);
avIncorrUnrewPlot = mean(avIncorrUnrewFrame, 2);

framesStack.rewStimFrames = rewStimFrames;
framesStack.unrewStimFrames = unrewStimFrames;
framesStack.corrRewFrames = corrRewFrames;
framesStack.corrUnrewFrames = corrUnrewFrames;
framesStack.incorrRewFrames = incorrRewFrames;
framesStack.incorrUnrewFrames = incorrUnrewFrames;

vsdRespStruc.avRewStimPlot = avRewStimPlot;
vsdRespStruc.avUnrewStimPlot = avUnrewStimPlot;
vsdRespStruc.avCorrRewPlot = avCorrRewPlot;
vsdRespStruc.avCorrUnrewPlot = avCorrUnrewPlot;
vsdRespStruc.avIncorrRewPlot = avIncorrRewPlot;
vsdRespStruc.avIncorrUnrewPlot = avIncorrUnrewPlot;

figure; 
plot(avRewStimPlot); 
hold on; 
plot(avUnrewStimPlot, 'r');
plot(avCorrRewPlot, 'g');
plot(avCorrUnrewPlot, 'k');
plot(avIncorrRewPlot, 'c');
plot(avIncorrUnrewPlot, 'm');