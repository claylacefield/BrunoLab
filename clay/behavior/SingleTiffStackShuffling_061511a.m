


%%

frameNum = 0;

% see how big the image stack is
stackInfo = imfinfo(filepath);
sizeStack = length(stackInfo);
clear stackInfo;

tifStack = zeros(256, 256, sizeStack);
%%

for i=1:3:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;
    imwrite(frame, 'outfile.tif')
end


    
    