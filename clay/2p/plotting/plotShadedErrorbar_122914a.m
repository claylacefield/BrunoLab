function plotShadedErrorbar(inStruc, fields)


fields = {'correctRewStimIndCaAvg' 'correctUnrewStimIndCaAvg'};

colors = {'-b' '-r' '-m' '-c'};

inStruc = group1Struc;

if ~isempty(strfind(fields{1}, 'timInd'))
    x = -2.25:0.25:5.75;
else
    x = -2:0.25:6;
end

y1 = inStruc.(fields{1});
sem1 = nanstd(y1,0,2)/sqrt(size(y1,2));
y2 = inStruc.(fields{2});
sem2 = nanstd(y2,0,2)/sqrt(size(y2,2));

figure;
line([0 0], [-0.04 0.1], 'Color', [0.8,0.8,0.8]);
hold on;
A=shadedErrorBar(x,nanmean(y1,2),sem1,'-b',1);
%hold on;
B=shadedErrorBar(x,nanmean(y2,2),sem2,'-r',1);
xlabel('seconds');
ylabel('dF/F');
title([fields{1} ' vs ' fields{2} ' calcium']);
