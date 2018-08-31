
% function 

%%

frameNum = 0;

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

tifStack = zeros(height, width, sizeStack, 'int16'); % must specify "int" or runs out of memory

%%

for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;
    %imwrite(frame, 'outfile.tif')
end

% NOTE: this loop takes a long time to process- think of alternative
    
    