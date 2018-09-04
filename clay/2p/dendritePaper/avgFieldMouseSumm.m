function  [compilVals] = avgFieldMouseSumm(mouseSummCell, summStrucFields, varargin)

if length(varargin) == 4
    somaDendTag = varargin{1};  % e.g. 's' for soma, 'd' for dend
    progNameTag = varargin{2};  % e.g. 'Skip' for normal detection task, or 'sepChoice', 'stage1'
    avgColTag = varargin{3};    % which column to compute averages for (e.g. 'correctRewStimIndCa', 'fullSessionXcorr')
    toAvgTrials = varargin{4};  % to average all trials in each session
elseif length(varargin) == 2
    
end

%disp(progNameTag);

%load('/home/clay/Documents/Data/2p mouse behavior/summStrucFields_040617a.mat');
% NOTE: this doesn't include first two columns added in compil script

% somaDendColNum = find(not(cellfun('isempty', strfind(summStrucFields, somaDendTag))))+2;
% progNameColNum = find(not(cellfun('isempty', strfind(summStrucFields, progNameTag))))+2;
somaDendColNum = 6;
progNameColNum = 7;

avgColNum = find(not(cellfun('isempty', strfind(summStrucFields, avgColTag))))+2;


progRows = find(not(cellfun('isempty', strfind(mouseSummCell(:,progNameColNum), progNameTag))));

%sdArr = {'d','s'};


somaRows = find(not(cellfun('isempty', strfind(mouseSummCell(:,somaDendColNum), somaDendTag))));

procRows = intersect(somaRows, progRows);

compilVals = [];
for i = 1:length(procRows)
   fieldVals = mouseSummCell{procRows(i), avgColNum}; 
   if toAvgTrials == 1
    fieldVals = nanmean(fieldVals, 2);
   end
   compilVals = [compilVals fieldVals];
end

% sem = nanstd(compilVals,0,2)/sqrt(size(compilVals,2));
% 
% figure; 
% errorbar(mean(compilVals,2), sem);
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


