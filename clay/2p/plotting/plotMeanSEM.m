function plotMeanSEM(ca, color)

if size(ca,1) == 33
    fps = 4;
    xAx = -2:1/fps:6;
else 
    xAx = 1:size(ca,1);
end



sem = nanstd(ca,0,2)/sqrt(size(ca,2));

errorbar(xAx, nanmean(ca, 2),sem, color); xlim([xAx(1) xAx(end)]);