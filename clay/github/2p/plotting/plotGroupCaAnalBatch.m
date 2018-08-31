function [groupDendAvgStruc] = plotGroupCaAnalBatch(groupStruc, range)

% Plotting script for data from dendriteBehavAnalysis

% NOTE 122513: I think this is an older script that I used when I was manually
% constructing the group structures

% INPUT fps of struc in workspace to analyze
%hz = 4;
%hz=fps;

% [filename, pathname] = uigetfile('*.mat', 'Select a batchDendStruc to read');

% cd(pathname);
% load(filename);
% 
% hz = str2num(filename((strfind(filename, 'hz')-1)));
% 
% % load desired struc from workspace (dep on fps)
% batchDendStruc = eval(['batchDendStruc' num2str(hz) 'hz']); 



for i = 1:size(groupStruc, 2)   % for each animal in the groupStruc
    
    batchDendStruc = groupStruc(i).batchDendStruc; % load in their batchDendStruc
    
    fieldNames = fieldnames(batchDendStruc);
    
    
    for field = 1:length(fieldNames)    % then for each field/event
        
        if strfind(fieldNames{field}, 'CaAvg')
            
        eventName = genvarname(fieldNames{field});
                            
%         % now construct the names of the event ca signals
%         eventNameCa = [eventName 'Ca'];
        eventNameCaAvg = [eventName 'CaAvg'];
        
        if ~isempty(batchDendStruc.(fieldNames{field})) % if it's not empty
            
            eventCa = batchDendStruc.(fieldNames{field});
            
            % if you only want to take first X days of imaging
            if range > 0
                if size(eventCa, 2) > range
                    lastDay = range;
                else
                    lastDay = size(eventCa, 2);
                    
                end
            else
                lastDay = size(eventCa,2);
            end
            
            
            eventCaAvg = mean(eventCa(:,1:lastDay), 2);  % take mean of all days for this event/animal
            
            eval([eventNameCaAvg '(:,i) = eventCaAvg;' ]);
            
            % and put into structure for this day
            % groupDendAvgStruc.(eventNameCa) = eventCa;
            groupDendAvgStruc.(eventNameCaAvg(1:(length(eventNameCaAvg)-5))) = eval(eventNameCaAvg);
            
        end
        
        end
        
    end
    
    clear batchDendStruc;
    
    
end
% 
% % and some variables for plotting
% startX = 0; % 2*hz;
% stopX = 4;
% step = 1/hz;
% xAx = linspace(-2,6,8*hz+1);    % to make axis in sec (not frames)
% 
% 
% %% NOW PLOT EVERYTHING
% 
% figure;
% 
% subplot(3,3,1); %
% plot(xAx, rewardsCaAvgAvg); 
% title('rewards (b), punishments (r)');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, punTimeCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,2);
% plot(xAx, corrRewIndCaAvgAvg); 
% title('correct rew trials (b), incorr rew trials (r)');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, incorrRewIndCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,3);
% plot(xAx, corrUnrewIndCaAvgAvg); 
% title('correct unrew trials (b), incorr unrew trials (r)');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, incorrUnrewIndCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,4);
% plot(xAx, corrRewIndCaAvgAvg); 
% title('correct rew (b), and unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, corrUnrewIndCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,5);
% plot(xAx, incorrRewIndCaAvgAvg); 
% title('incorrect rew (b), and unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, incorrUnrewIndCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,6);
% plot(xAx, incorrRewIndCaAvgAvg); 
% title('incorrect rew (b), and correct unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, corrUnrewIndCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,7);
% plot(xAx, corrRewIndCaAvgAvg); 
% title('correct rew (b), and incorrect unrew (r) trials');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, incorrUnrewIndCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off;
% 
% subplot(3,3,8);
% plot(xAx, corrFirstContactTimesCaAvgAvg); 
% title('correct (b), and incorrect rew trial (r) first whisker contacts');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% plot(xAx, incorrFirstContactTimesCaAvgAvg, 'r'); 
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
% hold off; 
% 
% subplot(3,3,9);
% plot(xAx, corrRewIndCaAvg); 
% title('rewStimInd (each day)');
% ylabel('dF/F'); xlabel('sec'); 
% hold on;
% yL = get(gca, 'YLim');
% line([startX startX],yL, 'Color', 'g');
% line([stopX stopX],yL, 'Color', 'r');
