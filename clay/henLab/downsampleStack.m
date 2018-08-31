function [Y] = downsampleStack(Y, spatDs, tempDs)


[ydim, xdim, t] = size(Y);

spatDs = 1/spatDs;

disp('Downsampling spatial by 2x'); tic;
for frNum = 1:t
   Y2(:,:,frNum) = imresize(Y(:,:,frNum),spatDs); 
end
toc;

[ydim, xdim, t] = size(Y2);
Y3 = reshape(Y2, (ydim*xdim), t);

disp('Downsampling temporal by 2x'); tic;
Y4 = zeros((ydim*xdim), t/tempDs);
for pixNum = 1:size(Y3,1)
    Y4(pixNum,:) = decimate(double(Y3(pixNum,:)), tempDs);
end
toc;

Y = reshape(Y4,ydim, xdim, t/tempDs);

%Y = uint16(Y);