function [ multielecBehavStruc] = multielecBehavAnalysis(nChannels, sf)

% Master script for looking at behavior-triggered average Lfplcium signals

%% NOTE:
% Lfpn make this script a lot shorter by indexing the structures and looping
% through the different event type times instead of specifying each one
% independently
% Lfpn read out structure field names with:
% fn = fieldnames(eventStruc);
% for m = 1:length(fn)
%   eventTimes = eventStruc.(fn{m});  % reads the fieldname in list
%   outputStruc.([fn{m} 'Avg']) = eventTimes;  % and writes to field in list
% end
%



avg = 1; ch = 1; 


%% Detect behavioral event times from BIN file and event type indices from TXT
% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

[eventStruc] = detect16chEvents(nChannels, sf);


% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

stimTrig = eventStruc.stimTrig;

corrRewInd = eventStruc.corrRewInd;
incorrRewInd = eventStruc.incorrRewInd;
corrUnrewInd = eventStruc.corrUnrewInd;
incorrUnrewInd = eventStruc.incorrUnrewInd;

corrRewStimTimes = stimTrig(corrRewInd);
incorrRewStimTimes = stimTrig(incorrRewInd);
corrUnrewStimTimes = stimTrig(corrUnrewInd);
incorrUnrewStimTimes = stimTrig(incorrUnrewInd);

firstContactTimes = eventStruc.firstContactTimes;
corrFirstContactTimes = eventStruc.corrFirstContactTimes;
incorrFirstContactTimes = eventStruc.incorrFirstContactTimes;

rewardTimes = eventStruc.rewards;
lickTimes = eventStruc.licks;
punTimes = eventStruc.punTime;

levPress = eventStruc.levPress;
levLift = eventStruc.levLift;

preFrame = 2*sf;
postFrame = 6*sf;

%% Open 16ch multielectrode data

x = binRead2p(16,sf);
x=x'; x = x(:,size(x,2):-1:1);

%% Correct rewarded stimuli

beginInd = corrRewStimTimes - preFrame;
endInd = corrRewStimTimes + postFrame;

%epochLength = endInd(1)-beginInd(1);

for k = 1:length(endInd)
    
    corrRewLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrRewLfp(:,k));
    
end

corrRewLfpAvg = mean(corrRewLfp, 3);

multielecBehavStruc.corrRewLfp  =  corrRewLfp;
multielecBehavStruc.corrRewLfpAvg  =  corrRewLfpAvg;

% figure; plot(corrRewLfpAvg); hold on;
% title('correct and incorrect rewarded trial whole frame Lfp avgs');

%% Incorrect rewarded stimuli

beginInd = incorrRewStimTimes - preFrame;
endInd = incorrRewStimTimes + postFrame;

for k = 1:length(endInd)
    
    incorrRewLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(incorrRewLfp(:,k), 'r');
    
end

incorrRewLfpAvg = mean(incorrRewLfp, 3);

multielecBehavStruc.incorrRewLfp  =  incorrRewLfp;
multielecBehavStruc.incorrRewLfpAvg  =  incorrRewLfpAvg;

% plot(incorrRewLfpAvg, 'r'); hold off;

%% Correct unrewarded stimuli

beginInd = corrUnrewStimTimes - preFrame;
endInd = corrUnrewStimTimes + postFrame;

for k = 1:length(endInd)
    
    corrUnrewLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrUnrewLfp(:,k));
    
end

corrUnrewLfpAvg = mean(corrUnrewLfp, 3);

multielecBehavStruc.corrUnrewLfp  =  corrUnrewLfp;
multielecBehavStruc.corrUnrewLfpAvg  =  corrUnrewLfpAvg;
% 
% figure; plot(corrUnrewLfpAvg); hold on;
% title('correct and incorrect unrewarded trial whole frame Lfp avgs');


%% Incorrect unrewarded stimuli

beginInd = incorrUnrewStimTimes - preFrame;
endInd = incorrUnrewStimTimes + postFrame;

for k = 1:length(endInd)
    
    incorrUnrewLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(incorrUnrewLfp(:,k), 'r');
    
end

incorrUnrewLfpAvg = mean(incorrUnrewLfp, 2);

multielecBehavStruc.incorrUnrewLfp  =  incorrUnrewLfp;
multielecBehavStruc.incorrUnrewLfpAvg  =  incorrUnrewLfpAvg;

% plot(incorrUnrewLfpAvg, 'r'); hold off;

%% Correct first contacts

corrFirstContactTimes = corrFirstContactTimes(find(corrFirstContactTimes));

beginInd = corrFirstContactTimes - preFrame;
endInd = corrFirstContactTimes + postFrame;

for k = 1:length(endInd)
    
   corrFirstContactLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    

%         for chNum = 1:size(x,2)
%             chDf = chStruc(:,chNum);
%             corrFirstContactLfp (:,chNum,k)= x(beginInd(k):endInd(k));
%             
%         end

    
end


    corrFirstContactLfpAvg = mean(corrFirstContactLfp,3);
%     corrFirstContactLfpAvgAvg = mean(corrFirstContactLfpAvg,2);


%corrFirstContactLfpAvg = mean(corrFirstContactLfp, 2);

multielecBehavStruc.corrFirstContactLfp  =  corrFirstContactLfp;
multielecBehavStruc.corrFirstContactLfpAvg  =  corrFirstContactLfpAvg;

% figure; plot(corrFirstContactLfpAvg); hold on;
% title('correct and incorrect first whisker contact whole frame Lfp avgs');

%% Incorrect first contacts

incorrFirstContactTimes = incorrFirstContactTimes(find(incorrFirstContactTimes ~= 0));

beginInd = incorrFirstContactTimes - preFrame;
endInd = incorrFirstContactTimes + postFrame;

for k = 1:length(endInd)
    
    incorrFirstContactLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
%     if ch == 1
%         for chNum = 1:length(chStruc)
%             chDf = chStruc(chNum).chDf;
%             chincorrFirstContactLfp (:,chNum,k)= chDf(beginInd(k):endInd(k));            
%         end
%     end
    
end

% if ch == 1
%     chincorrFirstContactLfpAvg = mean(chincorrFirstContactLfp,3);
%     chincorrFirstContactLfpAvgAvg = mean(chincorrFirstContactLfpAvg,2);
% end

incorrFirstContactLfpAvg = mean(incorrFirstContactLfp, 3);

multielecBehavStruc.incorrFirstContactLfp  =  incorrFirstContactLfp;
multielecBehavStruc.incorrFirstContactLfpAvg  =  incorrFirstContactLfpAvg;%% Correct first contacts


% plot(incorrFirstContactLfpAvg, 'r'); hold off;

%% all first contacts

beginInd = firstContactTimes - preFrame;
endInd = firstContactTimes + postFrame;

for k = 1:length(endInd)
    
    firstContactLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrRewLfp(:,k));
    
end

firstContactLfpAvg = mean(firstContactLfp, 3);

multielecBehavStruc.firstContactLfp  =  firstContactLfp;
multielecBehavStruc.firstContactLfpAvg  =  firstContactLfpAvg;


%% all rewards

beginInd = rewardTimes - preFrame;
endInd = rewardTimes + postFrame;

for k = 1:length(endInd)
    
    rewardLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    % rewTif(:,:,1:(preFrame + postFrame +1),k) = tifStack(:,:,beginInd(k):endInd(k));
    
    %plot(corrRewLfp(:,k));
    
end

% rewTifAvg = uint16(mean(rewTif, 4));

% rewTifAvgDf = rewTifAvg.-tifAvg;

% for i = 1:size(rewTifAvg, 3) 
%     rewTifAvgDf = rewTifAvg(:,:,i)-tifAvg;
%     imwrite(rewTifAvg(:,:,i), 'rewTifAvg.tif', 'writemode', 'append'); 
% end

rewardLfpAvg = mean(rewardLfp, 3);

multielecBehavStruc.rewardLfp  =  rewardLfp;
multielecBehavStruc.rewardLfpAvg  =  rewardLfpAvg;

figure; plot(rewardLfpAvg); hold on;
title('reward, punishment, and lick whole frame Lfp avgs');

%% all punishments

beginInd = punTimes - preFrame;
endInd = punTimes + postFrame;

for k = 1:length(endInd)
    
    punLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrRewLfp(:,k));
    
end

punLfpAvg = mean(punLfp, 3);

multielecBehavStruc.punLfp  =  punLfp;
multielecBehavStruc.punLfpAvg  =  punLfpAvg;

plot(punLfpAvg, 'r');

%% all licks

beginInd = lickTimes - preFrame;
endInd = lickTimes + postFrame;

for k = 1:length(endInd)
    
    lickLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrRewLfp(:,k));
    
end

lickLfpAvg = mean(lickLfp, 3);

multielecBehavStruc.lickLfp  =  lickLfp;
multielecBehavStruc.lickLfpAvg  =  lickLfpAvg;

plot(lickLfpAvg, 'g'); hold off;

%% lever presses

beginInd = levPress - preFrame;
endInd = levPress + postFrame;

for k = 1:length(endInd)
    
    levPressLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrRewLfp(:,k));
    
end

levPressLfpAvg = mean(levPressLfp, 3);

multielecBehavStruc.levPressLfp  =  levPressLfp;
multielecBehavStruc.levPressLfpAvg  =  levPressLfpAvg;

figure; plot(levPressLfpAvg); hold on;
title('lever presses and lifts Lfp Avg');

%% lever lifts

beginInd = levLift - preFrame;
endInd = levLift + postFrame;

for k = 1:length(endInd)
    
    levLiftLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    
    %plot(corrRewLfp(:,k));
    
end

levLiftLfpAvg = mean(levLiftLfp, 2);

multielecBehavStruc.levLiftLfp  =  levLiftLfp;
multielecBehavStruc.levLiftLfpAvg  =  levLiftLfpAvg;

plot(levLiftLfpAvg, 'g'); hold off;

%%
% So, what else do I need to make?
% - look at averages for:
% - all stim
% - 
% - 
%
%
