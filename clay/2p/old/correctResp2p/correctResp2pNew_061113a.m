
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
fullCell = fullCell(beginInd:length(fullCell));
fullCell = [fullCell; 'pad'; '0'];  % and pad the end in case it ends with an event trigger

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
rewStimOutcomeInds = rewStimCellInds + 2;
corrRewStimInds = rewStimInds(strcmp(fullCell(rewStimOutcomeInds), 'REWARD!!!')); 
incorrRewStimInds = rewStimInds(~strcmp(fullCell(rewStimOutcomeInds), 'REWARD!!!'));
switchRewStimInds = rewStimInds(strcmp(fullCell(rewStimOutcomeInds), 'rew>pun switch'));

unrewStimOutcomeInds = unrewStimCellInds + 2;
incorrUnrewStimInds = unrewStimInds(strcmp(fullCell(unrewStimOutcomeInds), 'unrewarded lever press')); 
corrUnrewStimInds = unrewStimInds(~strcmp(fullCell(unrewStimOutcomeInds), 'unrewarded lever press'));
switchUnrewStimInds = unrewStimInds(strcmp(fullCell(unrewStimOutcomeInds), 'pun>rew switch'));

catchStimOutcomeInds = catchStimCellInds + 2;
incorrCatchStimInds = catchStimInds(strcmp(fullCell(catchStimOutcomeInds), 'unrewarded lever press')); 
corrCatchStimInds = catchStimInds(~strcmp(fullCell(catchStimOutcomeInds), 'unrewarded lever press'));
switchCatchStimInds = catchStimInds(strcmp(fullCell(catchStimOutcomeInds), 'pun>rew switch'));

% now build corrRespArr
corrRespArr = zeros(length(stimTypeArr), 1);
corrRespArr(corrRewStimInds) = 1;
try
corrRespArr(corrUnrewStimInds) = 1;
catch
corrRespArr(corrCatchStimInds) = 1;
end

% output needed variables to corrRespStruc
corrRespStruc.stimTypeArr = stimTypeArr;
corrRespStruc.corrRespArr = corrRespArr;



% things left to do:
% 1. make corrRespArr
% 2. do I use any other variables in other 2p scripts? only
% incorrLevPressLatency for getting punishments before I was recording pun
% sigs
% 3. find indices of skip events (may be multiple ones in occasional
% events)
% 4. save all necessary variables into corrRespStruc (only stimTypeArr and
% corrRespArr really needed? no, now need skip and switch indices too)
% 5. fix naming of some variables to agree with previous script