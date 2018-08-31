% Loads .AVI files and can be used as the basis of a video analysis script

% Prompt user to select file
[filename, pathname] = uigetfile('*.*');
filepath = fullfile(pathname, filename);

% open file
xyloObj = VideoReader(filepath);
nFrames = xyloObj.NumberOfFrames;
nFrames = 100;
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;

% color map for monochrome
cm = colormap(gray(256));
% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'), ...
         'colormap', cm);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(xyloObj, k);
end

% Size a figure based on the video's width and height.
hf = figure;
set(hf, 'position', [150 150 vidWidth vidHeight])

% Play back the movie once at the video's frame rate.
movie(hf, mov, 1, xyloObj.FrameRate);