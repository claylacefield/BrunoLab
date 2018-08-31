
% Script for analyzing whisker video data

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