function [tifStack] = readMcTifStackSima(basename, ch, endFr)

% script to read a tiff stack 
% Clay 2017
% basename = .tif file basename
% ch = channel to read; ch = 0, all frames, ch = 1, ch1 of 2, 2 ch2 of 2
% endFr = frame # to stop reading at

cd([basename '.sima']);

try
    tifPath = [basename 'b.tif'];
    stackInfo = imfinfo(tifPath); % for old motion corrected
catch
    tifPath = [basename '.tif'];
    stackInfo = imfinfo(tifPath);
end


disp(['Processing image stack for ' tifPath]);

% see how big the image stack is
%stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack (all channels)
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

if ch == 0
   numImCh = 1; 
   ch = 1;
else
    numImCh = 2;
end

maxFr = min([sizeStack endFr]);

frameNum = 0;

for i=ch:numImCh:maxFr
    frame = imread(tifPath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
end

cd ..;