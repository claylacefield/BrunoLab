function plotAFewFields2strucShaderrRange(inStruc1, inStruc2, fields, baselineFrames, preLimSec, postLimSec) % , useMice)


%% USAGE: plotAFewFieldsShaderr(inStruc, fields, baselineFrames);
% where fields is cell array of two fields, groupStruc2 is any group or
% dendriteBehavStruc, baselineFrames is array of baseline frames to
% subtract, (not using useMice now, it's for groupStruc).

%useMice = [7 8 9 11];

%fields = {'correctRewStimIndCaAvg' 'correctUnrewStimIndCaAvg'};

colors = {'-b' '-g' '-r' '-m'};

handleList = {'A' 'B' 'C' 'D'};

allFieldCaAvg = [];
allFieldSem = [];

for numStruc = 1:2
    fieldName = fields{numStruc};
    
    if numStruc == 1
    fieldCa = inStruc1.(fieldName);
    else
        fieldCa = inStruc2.(fieldName);
    end
    
%     if useMice == 0
%         useMice = 1:size(fieldCa, 2);
%     end
%     
%     fieldCa = fieldCa(:,useMice);
    %allFieldCa(:,:,field) = fieldCa;
    allFieldSem(:,numStruc) = nanstd(fieldCa,0,2)/sqrt(size(fieldCa,2));
    fieldCaAvg = nanmean(fieldCa,2);
    if baselineFrames ~= 0
        baseline = nanmean(fieldCaAvg(baselineFrames));
    else
        baseline = 0;
    end
    allFieldCaAvg(:,numStruc) = fieldCaAvg-baseline;
end

preLimFr = 9-preLimSec*4;
postLimFr = postLimSec*4+9;
% allFieldCaAvg = allFieldCaAvg(preLimFr:postLimFr,:);
% allFieldSem = allFieldSem(preLimFr:postLimFr,:);

for field = 1:length(fields)
   allFieldMin(field) = min(allFieldCaAvg(:,field)); 
   allFieldMax(field) = max(allFieldCaAvg(:,field)); 
end

maxY = max(allFieldMax);
minY = min(allFieldMin);


% plot the means of the event-trig Ca with sem
figure; hold on;
%line([0 0], [-0.1 0.2], 'Color', 'g');% [-0.06 0.08], 'Color', 'g');
%line([2 2], [-0.1 0.2], 'Color', 'r');% [-0.06 0.08], 'Color', 'r');
%line([4 4], [-0.1 0.25], 'Color', 'r');
line([0 0], [minY-0.02, maxY+0.05], 'Color', [0.8,0.8,0.8]);

% adjust zero time if using stimInd (bec stim movement is ~250ms after
% startTrig)
% if ~isempty(strfind(fields{1}, 'timInd'))
%     x = -(preLimSec+0.25):0.25:(postLimSec-0.25);
% else
    x = -preLimSec:0.25:postLimSec;
% end

for field = length(fields):-1:1
    eval( [handleList{field} ' = shadedErrorBar(x, allFieldCaAvg(preLimFr:postLimFr,field), allFieldSem(preLimFr:postLimFr,field), colors{field}, 1);']);
end

xlabel('seconds');
ylabel('dF/F');
title([fields{1} ' vs ' fields{2} ' calcium']);
%xlim(xLim);
ylim([minY-0.02, maxY+0.05]);

if length(fields) == 1
legend(A.mainLine, fields{1});
elseif length(fields) == 2
    legend([A.mainLine, B.mainLine], fields{1}, fields{2});
elseif length(fields) == 3
    legend([A.mainLine, B.mainLine, C.mainLine], fields{1}, fields{2}, fields{3});
elseif length(fields) == 4
    legend([A.mainLine, B.mainLine, C.mainLine, D.mainLine], fields{1}, fields{2}, fields{3}, fields{4});
end
% legend(fields{1}, fields{2});
% xlabel('sec');
% ylabel('dF/F');