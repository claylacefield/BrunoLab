
% This is a new script for reading behavioral events from .txt files
% output by the Processing script that records Arduino behavioral data
%
% It no longer reads through the events in a loop
%

% select .txt file of behavioral events
[filename pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
filepath = [pathname filename];

% now read in the TXT file as a cell array
fullCell= textread(filepath,'%s', 'delimiter', '\n');   % read in whole file as cell array

% now find the index of the first actual data point
beginInd = (find(strcmp(fullCell, 'BEGIN DATA'))+1);

% and make cell array start at first event
fullCell = fullCell{beginInd:length(fullCell)};

% find the cell array indices of stim triggers of particular types
rewStimCellInds = find(ismember(fullCell, 'stim trigger (bottom/rewarded)'));
unrewStimCellInds = find(ismember(fullCell, 'stim trigger (top/unrewarded)'));
catchStimCellInds = find(ismember(fullCell, 'stim trigger (catch trial)'));

% now concatenate and sort stims of all types
stimCellInds = sort([rewStimCellInds; unrewStimCellInds; catchStimCellInds]);

% find indices of events of certain types
rewStimInds = find(ismember(stimCellInds, rewStimCellInds));
unrewStimInds = find(ismember(stimCellInds, unrewStimCellInds));
catchStimInds = find(ismember(stimCellInds, catchStimCellInds));

% now build stimTypeArr from these
stimTypeArr = zeros(length(stimCellInds),1);
stimTypeArr(rewStimInds) = 1;
stimTypeArr(unrewStimInds) = 2;
stimTypeArr(catchStimInds) = 3;

% now see what outcomes of normal trials (i.e. not skip or switch) are
% NOTE: this is not completely working because it doesn't output event
% indices but indices in fullCell
rewStimOutcomeInds = rewStimCellInds + 2;
corrRewStimInds = stimCellInds(strcmp(fullCell(rewStimOutcomeInds), 'REWARD!!!')); 
switchRewStimInds = stimCellInds(strcmp(fullCell(rewStimOutcomeInds), 'rew>pun switch'));





