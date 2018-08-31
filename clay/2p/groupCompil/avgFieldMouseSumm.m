function  [compilVals] = avgFieldMouseSumm(mouseSummCell, varargin)

%% USAGE: [compilVals] = avgFieldMouseSumm(mouseSummCell, varargin);
% e.g. [compilVals] = avgFieldMouseSumm(mouseSummCell, 'd', 'RandDelay', 'rewStimStimIndCa', 1, 1);

if length(varargin) == 5
    somaDendTag = varargin{1};  % e.g. 's' for soma, 'd' for dend
    progNameTag = varargin{2};  % e.g. 'Skip' for normal detection task, or 'sepChoice', 'stage1'
    avgColTag = varargin{3};    % which column to compute averages for (e.g. 'correctRewStimIndCa', 'fullSessionXcorr')
    toAvgTrials = varargin{4};  % to average all trials in each session
    toPlot = varargin{5};
elseif length(varargin) == 2
    
end

%disp(progNameTag);

load('/home/clay/Documents/Data/2p mouse behavior/summStrucFields_012718a.mat');
% NOTE: this doesn't include first two columns added in compil script

% somaDendColNum = find(not(cellfun('isempty', strfind(summStrucFields, somaDendTag))))+2;
% progNameColNum = find(not(cellfun('isempty', strfind(summStrucFields, progNameTag))))+2;
somaDendColNum = 6;
progNameColNum = 7;


if ~isempty(strfind(avgColTag, '.'))
   strucName = avgColTag(1:strfind(avgColTag, '.')-1); 
   fieldName = avgColTag(strfind(avgColTag, '.')+1:end);
   avgColTag = strucName;
   isStruc = 1;
else
    isStruc = 0;
end

% avgColNum = find(not(cellfun('isempty', strfind(summStrucFields, avgColTag))))+2;
% progRows = find(not(cellfun('isempty', strfind(mouseSummCell(:,progNameColNum), progNameTag))));

avgColNum = find(contains(summStrucFields, avgColTag))+2;
progRows = find(contains(mouseSummCell(:,progNameColNum), progNameTag));

%sdArr = {'d','s'};

somaRows = find(not(cellfun('isempty', strfind(mouseSummCell(:,somaDendColNum), somaDendTag))));

procRows = intersect(somaRows, progRows);

compilVals = [];
for i = 1:length(procRows)
    try
    if isStruc == 0
        fieldVals = mouseSummCell{procRows(i), avgColNum};
    else
        inStruc = mouseSummCell{procRows(i), avgColNum};
        fieldVals = inStruc.(fieldName);
    end
    
    if length(size(fieldVals))==3
        fieldVals = squeeze(mean(fieldVals,2));
    end
    
    if toAvgTrials == 1
        fieldVals = nanmean(fieldVals, 2);
    end
    compilVals = [compilVals fieldVals];
    catch
        disp(['Field not present in ' mouseSummCell{procRows(i), 3}]);
    end
end

if toPlot
sem = nanstd(compilVals,0,2)/sqrt(size(compilVals,2));

figure; 
errorbar(mean(compilVals,2), sem);
if isStruc == 1
    avgColTag = [strucName '.' fieldName];
end
title([mouseSummCell{1,1} ' ' avgColTag]);
end


% 
% 
% somaRows = find(not(cellfun('isempty', strfind(mouseSummCell(:,somaDendColNum), 'd'))));
% 
% procRows = intersect(somaRows, progRows);
% 
% compilVals2 = [];
% for i = 1:length(procRows)
%    fieldVals = mouseSummCell{procRows(i), avgColNum}; 
%     compilVals2 = [compilVals2 fieldVals];
% end
% 
% sem2 = nanstd(compilVals2,0,2)/sqrt(size(compilVals2,2));
% 
% hold on; 
% errorbar(mean(compilVals2,2), sem2, 'r');


