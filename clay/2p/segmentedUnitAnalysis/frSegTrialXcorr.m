function [xcArr] = frSegTrialXcorr(segStruc, dendriteBehavStruc, segNum, field)

%% USAGE: [xcArr] = frSegTrialXcorr(segStruc, dendriteBehavStruc, segNum, field);
%% This script performs trial by trial xcorr between a segment calcium signal and the frame avg

segFieldDf = squeeze(segStruc.(field)(:,segNum, :));
frFieldDf = dendriteBehavStruc.(field);


for trial = 1:size(frFieldDf, 2)
    
    xcArr(:,trial) = xcorr(segFieldDf(:,trial), frFieldDf(:,trial));
    
end