

% Clay 011717
% script to overlay NMF results in stack with green and red channels 
% NOTE that you have to rescale the NMF output to around the max of the
% other channels

imwrite(uint16(avRed), 'testRGB2.tif');
imwrite(uint16(av), 'testRGB2.tif', 'WriteMode', 'append');
imwrite(uint16(6500*allSegIm/max(allSegIm(:))), 'testRGB2.tif', 'WriteMode', 'append');



