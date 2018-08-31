function [tifStack2] = readTifStack(filename, sizeStack, numImCh, saveTif)

basename = filename(1:strfind(filename, '.tif')-1);

numFrames = sizeStack;
frameNum = 0;

if saveTif
    try
        cd([basename '.sima']);
        firstFrame2 = imread(filename, 'tif', 1);
        width2 = size(firstFrame2,1);
        height2 = size(firstFrame2,2);
        
        tifStack2 = zeros(width2, height2, sizeStack);
        
        % now load all tifs in stack into 3D matrix
        for i=1:numImCh:sizeStack
            %frame = imread(tifpath, 'tif', i); % open the TIF frame
            frameNum = frameNum + 1;
            tifStack2(:,:,frameNum) = imread(filename, 'tif', i);
        end
    catch
        disp('Could not load sima corrected, so using original'); % so using original .tif');
        cd ..; %([dayPath dayDir(b).name]);
        firstFrame = imread(filename, 'tif', 1);
        width = size(firstFrame,1);
        height = size(firstFrame,2);
        
        tifStack = zeros(width, height, numFrames);
        for i=1:numImCh:sizeStack
            frameNum = frameNum + 1;
            tifStack(:,:,frameNum) = imread(filename, 'tif', i);
        end
        tifStack2 = tifStack;
    end
    
else
    disp('Not saving stimTifs so just use uncorrected');
    firstFrame = imread(filename, 'tif', 1);
        width = size(firstFrame,1);
        height = size(firstFrame,2);
        
    tifStack = zeros(width, height, numFrames);
    for i=1:numImCh:sizeStack
        frameNum = frameNum + 1;
        tifStack(:,:,frameNum) = imread(filename, 'tif', i);
    end
    tifStack2 = tifStack;
end


