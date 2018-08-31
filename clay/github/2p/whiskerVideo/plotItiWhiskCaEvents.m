function plotItiWhiskCaEvents(itiWhiskStruc)



norewItiCa = itiWhiskStruc.itiWhiskBoutCa;
rewItiCa = itiWhiskStruc.rewItiWhiskBoutCa;

norewItiAngle = itiWhiskStruc.itiWhiskBoutAngle;
rewItiAngle = itiWhiskStruc.rewItiWhiskBoutAngle;


for i = 1:size(norewItiCa,2)
    figure;
    subplot(2,1,1);
    plot(norewItiCa(:,i));
    title(['noRewIti event #' num2str(i)]);
    subplot(2,1,2);
    plot(norewItiAngle(:,i));
    
end


% for i = 1:size(rewItiCa,2)
%     figure;
%     subplot(2,1,1);
%     plot(rewItiCa(:,i));
%     title(['rewIti event #' num2str(i)]);
%     subplot(2,1,2);
%     plot(rewItiAngle(:,i));
%     
% end



% whiskAirPks = [];
% 
% for trial = 1:length(stimTrigTime)
%     whiskAirPks = [whiskAirPks wPks((wPkTimes<(stimTrigTime(trial)-1000)) & (wPkTimes>(stimTrigTime(trial)-2000)))];
% end





