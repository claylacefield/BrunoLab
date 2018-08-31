function [tifStack] = readTifStackSimple(varargin)

%% This is a script to import TIFF stacks of 2photon data
%  into the MATLAB workspace for analysis
%
%  clay061917

if length(varargin)==0
    [filename, pathname] = uigetfile('*.tif');
    tifpath = [pathname filename];
elseif length(varargin) ==1
    tifpath = varargin{1};
end

disp(['Processing image stack for ' tifpath]);

% see how big the image stack is
disp('Getting stack info'); tic;
stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
toc;
sizeStack = length(stackInfo);  % no. frames in stack (all channels)
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

tifStack = zeros(height, width, sizeStack);
disp('Reading in frames');
tic;
for i=1:sizeStack
    frame = imread(tifpath, 'tif', i); % open the TIF frame
    tifStack(:,:,i)= frame;  % make into a TIF stack
    
    if mod(i,500)==0
        disp(['Reading in frame #' num2str(i) ' out of ' num2str(sizeStack)]);
    end
    
end
toc;

