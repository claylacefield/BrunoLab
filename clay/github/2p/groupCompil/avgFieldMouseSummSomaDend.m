function [dendVals, somaVals] = avgFieldMouseSummSomaDend(mouseSummCell, progNameTag, eventName, toAvgTrials, toPlot)

% Clay 2017
% This function outputs eventVals for soma/dend from a mouseCell, on days
% in which both are present.

load('/home/clay/Documents/Data/2p mouse behavior/summStrucFields_040617a.mat');
avgColNum = find(not(cellfun('isempty', strfind(summStrucFields, eventName))))+2;

prevDay = [];

dendVals = [];
somaVals = [];

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
                    elseif sum(strcmp(somaDend, 'd'))>0
                        dendVals = [dendVals fieldVals];
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
plotMeanSEM(somaVals, 'r');
hold on; 
plotMeanSEM(dendVals, 'b');
legend('soma', 'dend');
title([mouseSummCell{1,1} ' ' progNameTag ' ' eventName ' soma vs. dend (matched) on ' date]);
xlabel('secs');
ylabel('dF/F');
end