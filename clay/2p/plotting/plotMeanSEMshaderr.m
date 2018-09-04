function plotMeanSEMshaderr(ca, color, varargin)


if size(ca,1) == 33
    fps = 4;
    xAx = -2:1/fps:6;
else 
    xAx = 1:size(ca,1);
end



sem = nanstd(ca,0,2)/sqrt(size(ca,2));
avCa = nanmean(ca,2);

if size(varargin)==1
    baselineFr = varargin{1};
avCa = avCa - avCa(baselineFr);
end

%errorbar(xAx, nanmean(ca, 2),sem, 'Color', color); xlim([xAx(1) xAx(end)]);

shadedErrorBar(xAx, avCa, sem, color, 1);