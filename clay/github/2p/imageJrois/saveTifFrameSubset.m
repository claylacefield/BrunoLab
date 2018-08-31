function saveTifFrameSubset(twoChan, lastFrame)

% this is a script to either cut out diode signals interleaved between Ca
% signal frames in a TIF stack, or to truncate the stack if there was a
% problem near the end
% This is important for motion correction and subsequent segmentation


%% Import the image stack

frameNum = 0;

% if nargin < 1
[filename, pathname] = uigetfile('*.tif', 'Select a multi-page TIFF to read');
filepath = [pathname filename];
% end

fileBasename = filename(1:strfind(filename, '.tif')-1);

cd(pathname);

% see how big the image stack is
stackInfo = imfinfo(filepath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

% preallocate space for TIF stack
tifStack = zeros(width, height, sizeStack);

disp('Loading in TIF stack');
tic;

for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
end

toc;

tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)

numFrames = sizeStack;

if lastFrame
    tifStack = tifStack(:,:,1:lastFrame);
end

if twoChan
    tifStack = tifStack(:,:,1:2:end);
end

disp(['Saving new TIF stack for ' filename]);
tic;

newName = [fileBasename '-1'];

cd('../');

mkdir(newName);  % make a folder with this name

cd(newName);

for i = 1:size(tifStack, 3)
    imwrite(uint16(tifStack(:,:,i)), [newName '.tif'], 'Compression', 'none', 'WriteMode', 'append');
end

% NOTE: this still doesn't work to write TIFs able to be subsequently
% motion corrected

cd('../');

toc;