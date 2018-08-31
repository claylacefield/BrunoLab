function plotMouseSummCaSomaDendDays(progNameTag)

load(findLatestFilename('mouseSummCell'));

numSess = size(mouseSummCell,1);

for i = 1:numSess
try
    if ~isempty(strfind(mouseSummCell{i,7}, progNameTag))

        dayStr = mouseSummCell{i,2};
        
        somaDend = mouseSummCell{i,6};
        rewCa = mouseSummCell{i,12};  % correctRew
        
        
        
        prevDayStr = dayStr;
        
    end
catch
end

end
        
        subplot(5,5,5*(j-1)+k);
        
        plotMeanSEM(unrewCa, 'r');
        hold on;
        plotMeanSEM(rewCa, 'b');
        %legend('unrew', 'rew');
        title([mouseSummCell{numSess,3}]);
        %xlabel('secs');
        %ylabel('dF/F');
        hold off;
        
