function [images, dx, dy, nFrames, nbits, filepath] = TIFFstackReader(filepath)

% Randy Bruno, July 2010

if nargin < 1
   [filename pathname] = uigetfile('*.tif', 'Select a multi-page TIFF to read');
   if filename == 0
       images = [];
       dx = 0;
       dy = 0;
       nFrames = 0;
       filepath = [];
       return;
   end
   filepath = fullfile(pathname, filename);
end

% get stack info
info = imfinfo(filepath);
dx = info.Width;
dy = info.Height;
nFrames = ncols(info);
nbits = info.BitDepth;

% allocate space for images
images = zeros(dy, dx, nFrames, 'uint16');

% read images
for i = 1:nFrames
    images(:,:,i) = imread(filepath, i);
end
