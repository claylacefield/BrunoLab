function [roiStruc] = getSimaROIprofiles(Y)

% Clay 011717
% This extracts ROI profiles from an ImageJ RoiSet.zip
% 
% based on:
% https://www.mathworks.com/matlabcentral/fileexchange/32479-readimagejroi-cstrfilenames-
% https://www.mathworks.com/matlabcentral/answers/144400-multiplying-a-2d-matrix-with-each-slice-of-3d-matrix

[yDim, xDim, T] = size(Y);

disp('Reading RoiSet.zip'); tic;
[rois] = ReadImageJROI('RoiSet.zip'); toc;


for roiNum = 1:length(rois)
    
    roiYX = [rois{roiNum}.mnCoordinates]; % extract ROI bound coord
    mask = poly2mask(roiYX(:,1),roiYX(:,2),yDim,xDim); % make into mask
    
    mPix = sum(mask(:)); % size of ROI in pixels
    
    disp(['Processing ROI # ' num2str(roiNum) ' out of ' num2str(length(rois))]);
    tic;
    
    masked = bsxfun(@times, Y, cast(mask, class(Y)));
    
    linMask = reshape(masked, yDim*xDim, T);
    roiAv = sum(linMask, 1)/mPix;
    
%     for frNum = 1:T
%         fr = squeeze(masked(:,:,frNum));
%         roiAv(frNum) = sum(fr(:))/mPix;
% %         maskFr = squeeze(Y(:,:,frNum)).*mask;
% %         roiAv(frNum) = sum(maskFr(:))/mPix;
%     end
    toc;
    
    roiStruc.roi(roiNum).roiYX = roiYX;
    roiStruc.roi(roiNum).roiAv = roiAv;
    
end

save(['roiStruc_' date '.mat'], 'roiStruc');