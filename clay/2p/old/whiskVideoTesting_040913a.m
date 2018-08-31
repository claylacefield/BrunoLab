
% Script for analyzing whisker video data

sf = 30;

%% Import the image stack

frameNum = 0;

[filename, pathname] = uigetfile('.tif');
tifpath = [pathname filename];

disp(['Processing image stack for ' filename]);
%tic;

% see how big the image stack is
stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

% extract number of imaging channels and only take green for
% Ca++ activity
numImCh = 1; % dataFileArray{rowInd, 11};

for i=1:numImCh:sizeStack
    frame = imread(tifpath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
end

tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)

numFrames = sizeStack;

s = uiimport; % GUI to import whisker ROI data (.txt from ImageJ)
imageJresults = s.data;

roi1 = imageJresults(:,3);  % roi from the region by whisker
roi2 = imageJresults(:,7);  % region never hit by whisker
sig = roi2-roi1;    % this subtracts out (some) camera scaling issues

MyFilt1=fir1(24,0.1,'high');  % [10 200]
filtSig = filtfilt(MyFilt1,1,sig);  % filter the whisker signal

dFiltSig = diff(filtSig);   % when whisker is changing is best measure of whisking

whisks = LocalMinima(dFiltSig, 2, -2); % (dFiltSig, sf/10,-2);


% plot stuff out
x = 1:length(frameNum);

figure; plot(sig-57); hold on; 
plot(filtSig, 'g');
plot(dFiltSig, 'y');
plot(x(whisks), dFiltSig(whisks), 'r.');