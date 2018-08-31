function [roiPkInd2] = roiPkDetect2(roiDf, fps)

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


roiRm = runmean(roiDf,5*fps);
roiDfRm = roiDf-roiRm;
roiThresh = std(roiDfRm)+0.05;

%roiPkInd1 = LocalMinima(-roiDfRm, fps, -roiThresh); 

roiPkInd2 = threshold(roiDf, roiThresh, fps);   % indices of Ca2+ pks
                                        