function plotMultStrucsFieldsShaderr(inStruc, fields, baselineFrames, preLimSec, postLimSec)

%function [meanCa, semCa] = plotMultStrucsFieldsShaderr(inStruc, fields, baselineFrames, preLimSec, postLimSec)


%% USAGE: plotAFewFieldsShaderr(inStruc, fields, baselineFrames);
% this version is for plotting a struc that is pre-constructed from
% different structures, e.g., 

%useMice = [7 8 9 11];

%fields = {'correctRewStimIndCaAvg' 'correctUnrewStimIndCaAvg'};

colors = jet(size(inStruc,2)*length(fields));

handleList = 'A':'Z';
handleList = handleList(1:length(colors));

fieldCell = {};
for struc = 1:size(inStruc,2)
    for field = 1:length(fields)
        fieldName = fields{field};
        fieldCell = [fieldCell fieldName];
        fieldCa = inStruc(struc).(fieldName);
        
        allFieldSem(:,struc,field) = nanstd(fieldCa,0,2)/sqrt(size(fieldCa,2));
        fieldCaAvg = nanmean(fieldCa,2);
        if baselineFrames ~= 0
            baseline = nanmean(fieldCaAvg(baselineFrames));
        else
            baseline = 0;
        end
        allFieldCaAvg(:,struc,field) = fieldCaAvg-baseline;
    end
end

% for field = 1:length(fields)
%    allFieldMin(field) = min(allFieldCaAvg(:)); 
%    allFieldMax(field) = max(allFieldCaAvg(:)); 
% end

maxY = max(allFieldCaAvg(:)+allFieldSem(:)); 
minY = min(allFieldCaAvg(:)-allFieldSem(:));


% plot the means of the event-trig Ca with sem
figure; hold on;
%line([0 0], [-0.1 0.2], 'Color', 'g');% [-0.06 0.08], 'Color', 'g');
%line([2 2], [-0.1 0.2], 'Color', 'r');% [-0.06 0.08], 'Color', 'r');
%line([4 4], [-0.1 0.25], 'Color', 'r');
line([0 0], [minY-0.04, maxY+0.04], 'Color', [0.8,0.8,0.8]);

preLimFr = preLimSec*4;
postLimFr = postLimSec*4+8;

% adjust zero time if using stimInd (bec stim movement is ~250ms after
% startTrig)
if ~isempty(strfind(fields{1}, 'timInd'))
    x = -2.25:0.25:5.75;
else
    x = -2:0.25:6; 
end

% if ~isempty(strfind(fields{1}, 'timInd'))
%     x = -(preLimSec+0.25):0.25:(postLimSec-0.25);
% else
%     x = -preLimSec:0.25:postLimSec;
% end
% 
% if ~isempty(strfind(fields{1}, 'timInd'))
%     preLimFr = preLimFr + 1;
%     postLimFr = postLimFr + 1;
% end
% 
% x = -preLimSec:0.25:postLimSec;

x = x(preLimFr:postLimFr);

x=x';

% figure; hold on;
n=0;
for struc = 1:size(inStruc,2)
    for field = 1:length(fields) %:-1:1
        n=n+1;
        color = colors(n,:);
        eval( [handleList(n) ' = shadedErrorBar(x, allFieldCaAvg(preLimFr:postLimFr,struc,field), allFieldSem(preLimFr:postLimFr,struc,field), {''Color'', color},1);']);
    end
end

xlabel('seconds');
ylabel('dF/F');
title([fields{1} ' vs ' fields{2} ' calcium']);
xlim([x(1), x(end)]);
ylim([minY-0.04, maxY+0.04]);

n = 0;
mainLineString = '';
fieldsString = '';
for numPlot = 1:size(colors,1)
    if numPlot ~= 1
        mainLineString = [mainLineString ', ' handleList(numPlot) '.mainLine'];
        fieldsString = [fieldsString ', fieldCell{' num2str(numPlot) '}'];
    else
        mainLineString = [handleList(numPlot) '.mainLine'];
        fieldsString = 'fieldCell{1}';
    end
    
end

eval(['legend([' mainLineString '], ' fieldsString ');']);

% % legend(fields{1}, fields{2});
% xlabel('sec');
% ylabel('dF/F');

% fullSessXcorr = allFieldCaAvg(:,4);
% fullSessSEM = allFieldSem(:,field);
