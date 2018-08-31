function correctMcTifTag()


% This script opens SIMA motion corrected data (saved with Python library)
% and corrects a tif tag problem

tifInfo = imfinfo('mc.tif');    % get info on motion corrected stack

if tifInfo(1).RowsPerStrip == 1     % see if this file has bad RowsPerStrip tag
    
    disp('Correcting mc.tif RowsPerStrip tag');
    tic;
    
    numFrames = length(tifInfo);    % find numFrames in stack
    myTif = Tiff('mc.tif', 'r+');    % open Tif object
    myTif2 = Tiff('mc2.tif', 'w');
    
    height = myTif.getTag('ImageLength');   % get height (class tag called 'ImageLength')
    
    % go through all the frames
    for frame = 1:numFrames
        myTif.setTag('RowsPerStrip', height);   % set tag correctly for this frame
        imgdata = myTif.read();  % read this image into workspace
        
        % need to rewrite some important tags based upon my data config
        tagstruct.ImageLength = size(imgdata,1);
        tagstruct.ImageWidth = size(imgdata,2);
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.RowsPerStrip = height;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software = 'MATLAB';
        myTif2.setTag(tagstruct);
        
        myTif2.write(imgdata);  % now write this image to the new stack
        myTif2.writeDirectory();   % rewrite this frame (need this but don't know why)
        
        if ~myTif.lastDirectory
            myTif.nextDirectory;    % then go to next frame (if not last)
            %myTif2.nextDirectory;
        end
        
    end
    
    
    
    myTif.close;    % then close tif objects
    myTif2.close;
    toc;
    
else
    disp('mc.tif tag already correct');
    
end