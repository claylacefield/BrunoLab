%%
% object tracking test
% after MATLAB training seminar
% 093010

%%
% imaqtool (MATLAB v2007b and later) to open camera and acquire single
% image

red = image1(:,:,3);

redInd = find(red > 180);  % to find a red object

threshImDoub = zeros(768, 1024);  % must be some other way to threshold image to logical
threshImDoub(redInd)=1;
threshIm = logical(threshImDoub);

obj1 = bwareaopen(threshIm, 50);  % erode objects less than 50 pixels
