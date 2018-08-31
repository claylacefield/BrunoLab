function msg = GetInfo(MCC)

% msg = GetInfo(MCC)
%
% INPUTS
%    MCC -- MClust cluster object
% 
% OUTPUTS
%    msg -- cell array message
%
% ADR 1999
% version 1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m


msg = {};
iM = 1;

global MClust_FeatureData MClust_FeatureNames
f = FindInCluster(MCC, MClust_FeatureData);

msg{iM} = [num2str(length(f)) ' points']; iM = iM+1;
msg{iM} = ''; iM = iM+1;
msg{iM} = 'Limits'; iM = iM+1;
for iL = 1:length(MCC.xdims)
   msg{iM} = ['   ' MClust_FeatureNames{MCC.xdims(iL)} ' x ' MClust_FeatureNames{MCC.ydims(iL)}]; iM = iM+1;
end