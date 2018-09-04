function [somaVals, dendVals, somaCellInds, dendCellInds] = avgFieldMouseSummSomaDend(mouseSummCell, summStrucFields, progNameTag, eventName, toAvgTrials, toPlot)

%% USAGE: [dendVals, somaVals] = avgFieldMouseSummSomaDend(mouseSummCell, summStrucFields, progNameTag, eventName, toAvgTrials, toPlot);
% Clay 2017
% This function outputs eventVals for soma/dend from a mouseCell, on days
% in which both are present.
% INPUTS:
% mouseSummCell: for any given mouse
% summStrucFields: cell array of field names in mouseSummCell
% progNameTag: e.g. 'Delay' for most normal catch, or 'Choice' for sepChoice 
% eventName: e.g. 'correctRewStimInd'
% toAvgTrials: 1 to avg trials by session and compile, or 0 to concat all
% trials
% toPlot: 1 to plot, 0 to not


%load('/home/clay/Documents/Data/2p mouse behavior/summStrucFields_040617a.mat');
avgColNum = find(not(cellfun('isempty', strfind(summStrucFields, eventName))))+2;

prevDay = [];

somaVals = [];
dendVals = [];

somaCellInds = [];
dendCellInds = [];

for i = 1:size(mouseSummCell,1) % for all rows in mouseCell
    day = mouseSummCell{i,2};   % extract day
    
    if ~strcmp(day, prevDay) && ~isempty(strfind(mouseSummCell{i,7}, progNameTag))  % if not same day as last (and is correct prog name)
        %somaDend = mouseSummCell{i,6};
        
        sameDayInd = find(strcmp(mouseSummCell(:,2), day)); % find all sessions from that day
        
        if length(sameDayInd)>1 % if more than one session from this day
            somaDends = mouseSummCell(sameDayInd,6); % find somaDend for these sessions
            
            if sum(strcmp(somaDends, 's'))>0 && sum(strcmp(somaDends, 'd'))>0 % if there is both soma and dend
                for j = 1:length(sameDayInd) % for each of these sessions
                    fieldVals = mouseSummCell{sameDayInd(j),avgColNum}; % extract the desired values
                    if toAvgTrials == 1
                        fieldVals = nanmean(fieldVals, 2);
                    end
                        
                    somaDend = mouseSummCell{sameDayInd(j),6}; % and extract somaDend
                    
                    if sum(strcmp(somaDend, 's'))>0
                        somaVals = [somaVals fieldVals];
                        somaCellInds = [somaCellInds sameDayInd(j)];
                    elseif sum(strcmp(somaDend, 'd'))>0
                        dendVals = [dendVals fieldVals];
                        dendCellInds = [dendCellInds sameDayInd(j)];
                    end
                    % NOTE: remember this might not work if some sessions
                    % recorded at diff rate
                    
                end
            end
            
        end
        
    end  % end IF new day
    prevDay = day;
end

if toPlot
figure;
try
plotMeanSEM(somaVals, 'r');
catch
    disp('No somaVals');
end
hold on; 
try
plotMeanSEM(dendVals, 'b');
catch
    disp('No dendVals');
end
legend('soma', 'dend');
title([mouseSummCell{1,1} ' ' progNameTag ' ' eventName ' soma vs. dend (matched) on ' date]);
xlabel('secs');
ylabel('dF/F');
end