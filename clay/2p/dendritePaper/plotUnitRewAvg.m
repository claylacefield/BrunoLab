function plotUnitRewAvg(unitCa);

% USAGE: plotUnitRewAvg(unitCa);
% Clay 2017
% Script to plot average unit ca, for dendrite paper (like L4,2/3 unit
% avgs)


unitCaAvg = mean(unitCa,2);

xAx = -2:0.25:6;

addYmax = 0.002;
addYmin = 0.002;

figure('pos', [10 10 640 320]); 
hold on;
plot(xAx, unitCaAvg, 'Color', [0.65 0.65 0.65], 'Linewidth', 2);
xlim([-2, 6]);
ylim([min(unitCaAvg)-addYmin max(unitCaAvg)+addYmax]);
line([0, 0], [min(unitCaAvg)-addYmin max(unitCaAvg)+addYmax], 'Color', 'k');
line([3, 3], [min(unitCaAvg)-addYmin max(unitCaAvg)+addYmax], 'LineStyle', '--', 'Color', 'k');
xlabel('seconds');


