function [roiPkInd1] = roiPkDetect1(roiDf, fps)

% other methods

%    roiSd = std(roiDf);
%    roiThresh = max(1*roiSd, 0.1);
%roiThresh = 0.04;

%diffRoiDf = [0; diff(roiDf)];
%droiSd = std(diffRoiDf);

% peaks with LocalMinima of runmean
%roiRm = runmean(diffRoiDf,2);
%roiDfRm = roiDf-roiRm;
%roiThresh = 2*std(roiDfRm);

%roiPkInd = LocalMinima(-roiDfRm, fps, -roiThresh);   % indices of Ca2+ pks


roiRm = runmean(roiDf,20);
roiDfRm = roiDf-roiRm;
roiThresh = std(roiDfRm);

roiPkInd1 = LocalMinima(-roiDfRm, fps, -roiThresh); 