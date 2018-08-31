% this is a script for analyzing animal path info extracted from video
% using ImageJ; NOTE: import only X and Y values extracted for both mice
% (using Particle Analyzer) and this will sort mouse#1 vs mouse#2 based upon L/R half of screen. NOTE
% ALSO: this is set for reduced size frames to speed operation, thus
% 360x240 pixels.
% In the future, will want to integrate inputs for frame dimensions and
% pixel/cm in order to get true spatial values instead of pixels.

x = stack1(:,3);   % create X and Y vectors for both mice
y = stack1(:,4);

mousInd1 = find(x <= 180);  % find mouse#1vs2 based upon X loc.
mousInd2 = find(x > 180);

mouse1x = x(mousInd1);   % record X and Y values for mouse #1 
mouse1y = y(mousInd1);   

mouse2x = x(mousInd2);  % or #2
mouse2y = y(mousInd2);

figure 
plot(mouse1x, mouse1y)   % and graph the two trajectories
xlim([0 360]);
ylim([0 240]);
hold on 
plot(mouse2x, mouse2y, 'r')