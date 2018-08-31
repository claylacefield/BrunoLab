function plotFactorSpatialCa(segStruc, seg, field)

% USAGE:
% This function plots a segmented factor spatial component 
% along with the field Ca

% ~110614: for plotting selected segment data (for SfN poster)

% extract spatial component
A = segStruc.A;
d1 = segStruc.d1;
d2 = segStruc.d2;

segSpatial = reshape(A(seg,:), d1, d2);

allSegFieldCa = segStruc.(field);

segFieldCa = squeeze(allSegFieldCa(:,seg,:));


xAx = -2:0.25:6;

figure;

%line([4 4], [-0.1 0.25], 'Color', 'r');

subplot(1,2,1);
imagesc(segSpatial);
title([segStruc.filename ' seg#' num2str(seg)]);

subplot(1,2,2);

line([0 0], [-0.01 1], 'Color', 'g');hold on;
line([3 3], [-0.01 1], 'Color', 'r');
plot(xAx, segFieldCa, 'b');
xlabel('sec');
ylabel('dF/F');
title(field);