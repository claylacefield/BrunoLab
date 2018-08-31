function plotAFewFieldsSEMsubplot(groupStruc2, fields, baselineFrames)  %, useMice)


%% USAGE: plotAFewFieldsSEM(groupStruc2, fields, baselineFrames, useMice);
% where fields is cell array of two fields, groupStruc2 is any group or
% dendriteBehavStruc, baselineFrames is array of baseline frames to
% subtract, (not using useMice now, it's for groupStruc).

%useMice = [7 8 9 11];

if size(groupStruc2.rewStimStimIndCaAvg, 1) ==33
    fps = 4;
elseif size(groupStruc2.rewStimStimIndCaAvg, 1) ==65
    fps = 8;
elseif size(groupStruc2.rewStimStimIndCaAvg, 1) ==17
    fps = 2;
end

for field = 1:length(fields)
    %%try
    fieldName = fields{field};
    fieldCa = groupStruc2.(fieldName);
    
%     if useMice == 0
%         useMice = 1:size(fieldCa, 2);
%     end
%     
%     fieldCa = fieldCa(:,useMice);
    %allFieldCa(:,:,field) = fieldCa;
    allFieldSem(:,field) = nanstd(fieldCa,0,2)/sqrt(size(fieldCa,2));
    fieldCaAvg = nanmean(fieldCa,2);
    if baselineFrames ~= 0
        baseline = mean(fieldCaAvg(baselineFrames));
    else
        baseline = 0;
    end
    allFieldCaAvg(:,field) = fieldCaAvg-baseline;
    %catch
    %end
end

[yMax yMaxInd] = max(allFieldCaAvg(:));
[yMin yMinInd] = min(allFieldCaAvg(:));

yMax = yMax + allFieldSem(yMaxInd);
yMin = yMin - allFieldSem(yMinInd);

%ylim([yMin-0.01 yMax+0.01]);

% plot the means of the event-trig Ca with sem
%figure; 
hold on;
line([0 0], [yMin-0.005 yMax+0.01], 'Color', [0.6 0.6 0.6]);% [-0.06 0.08], 'Color', 'g');
%line([2 2], [yMin yMax], 'Color', 'r');% [-0.06 0.08], 'Color', 'r');
%line([4 4], [-0.1 0.25], 'Color', 'r');
colors = {'b' 'g' 'r'};

xAx = linspace(-2,6, 8*fps+1); %:0.0033333:6; %

for field = 1:length(fields)
    try
    h(field) = errorbar(xAx, allFieldCaAvg(:,field), allFieldSem(:,field), 'Color', colors{field});
    catch
    end
end

%line([0 0], [-0.025 0.06], 'Color', 'g');

ylim([yMin-0.005 yMax+0.01]);
xlim([-2 6]);

if length(fields) > 1
legend([h(1),h(2)], fields{1}, fields{2});
end

%legend(fields{1}, fields{2});
xlabel('sec');
ylabel('dF/F');
hold off;