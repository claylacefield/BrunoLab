function [dendriteBehavStruc, eventStruc, x2] = dendriteBehavAnalysisOutputAll(fps) % nChannels, fps, avg, roi)

% [ dendriteBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, fps, avg, roi)
% Master script for looking at behavior-triggered average calcium signals

nChannels = 8;
% fps = 4;
avg = 0;
roi = 0;



%% Import the image stack

frameNum = 0;

% if nargin < 1
[filename pathname] = uigetfile('*.tif', 'Select a multi-page TIFF to read');
filepath = [pathname filename];
% end

cd(pathname);

% see how big the image stack is
stackInfo = imfinfo(filepath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big

for i=1:sizeStack
    frame = imread(filepath, 'tif', i); % open the TIF frame
    frameNum = frameNum + 1;
    tifStack(:,:,frameNum)= frame;  % make into a TIF stack
    %imwrite(frame*10, 'outfile.tif')
end

tifAvg = uint16(mean(tifStack, 3)); % calculate the mean image (and convert to uint16)

numFrames = sizeStack;

%% Calculate ROI profiles
% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity
% NOTE: select all ROIs first, then whole frame avg

% avg = 1; roi = 1; % specify wheter to process frame mean profile and ROI profiles

if avg == 1 || roi == 1
    [roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);
end

if avg == 0
    frameAvg = mean(mean(tifStack,1),2);  % take average for each frame
    frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
    % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
    
    % now doing this with the running mean (runmean from Matlab
    % Cntrl)
    
    runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
    
    frameAvgDf = (frameAvg - runAvg)./runAvg;
    
    % figure; plot(frameAvgDf);
end


%% Detect behavioral event times from BIN file and event type indices from TXT
% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

[eventStruc, x2] = detect2pEvents(fps); %nChannels,1000);  % detect2pEvents(nChannels, sf);


% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

% go ahead and unpack these because we're going to use it many times
frameTrig = eventStruc.frameTrig;
stimTrig = eventStruc.stimTrigTime;

fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names

preFrame = 2*fps;    % number of frames to take before and after event time
postFrame = 6*fps;

% this loop unpacks all the structure fields into variables of the same name
for field = 1:length(fieldNames)
    
    if ~isempty(eventStruc.(fieldNames{field}))
        
        % don't process stimTrig, frameTrig, and firstContactAbsT
        if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
            
            eventName = genvarname(fieldNames{field});
            
            % if these are indices of trials, find corresponding times
            if strfind(fieldNames{field}, 'StimInd')
                eventTimes = stimTrig(eventStruc.(fieldNames{field}));
            elseif strfind(fieldNames{field}, 'Time')
                eventTimes = eventStruc.(fieldNames{field});
%             else eventTimes = 0;
            end
            
            try
            eventTimes = eventTimes(eventTimes > frameTrig(1) & eventTimes < frameTrig(end));
            
            % eventEpochTool; % use subfunction to calculate event-trig Ca activ
            
            for j=1:length(eventTimes)
                zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
            end
            
            % then find indices of a window around the event
            beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
            okInd = find(beginFrame > 0 & beginFrame < numFrames);  % make sure indices are all positive
            beginFrame = beginFrame(okInd); % and only take these
            zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
            
            endFrame = zeroFrame + postFrame;
            okInd = find(endFrame > 0 & endFrame < numFrames); %
            endFrame = endFrame(okInd);
            zeroFrame = zeroFrame(okInd);   % just keep updated zeroFrames list for good measure
            
            for k = 1:length(endFrame)
                
                eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
                
                %             if roi == 1
                %                 for roiNum = 1:length(roiStruc)
                %                     roiDf = roiStruc(roiNum).roiDf;
                %                     ROIcorrFirstContactCa (:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
                %
                %                 end
                %             end
                
                %plot(corrRewCa(:,k));
                
            end
            
            eventCaAvg = mean(eventCa, 2);
            
            %eval([eventName ' = eventStruc.(fieldNames{field})']);
            
            eventNameCa = [eventName 'Ca'];
            eventNameCaAvg = [eventName 'CaAvg'];
            
            dendriteBehavStruc.(eventNameCa) = eventCa;
            dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
            
            clear zeroFrame eventCa eventCaAvg;
            
            catch
            end
            
        end
        
    end
end


% now just save the output structure in this directory
fn = filename(1:(strfind(filename, '.tif')-1));

save([fn '_dendriteBehavStruc' date], 'dendriteBehavStruc');


plotDendBehavAnal(dendriteBehavStruc, filename, fps);

hgsave([fn '.fig']);

%
%
%
%
%
% % corrRewStimTimes corrRewCa corrRewCaAvg
% % incorrRewStimTimes incorrRewCa incorrRewCaAvg
% % corrUnrewStimTimes corrUnrewCa
% % incorrUnrewStimTimes incorrUnrewCa
% % corrFirstContactTimes corrFirstContactCa
% % incorrFirstContactTimes incorrFirstContactCa
% % firstContactTimes firstContactCa
% % rewardTimes rewardCa
% % punTimes punCa
% % lickTimes lickCa
% % levPress levPressCa
% % levLift levLiftCa
%
%
% %% Correct rewarded stimuli
%
% % find the next frame indices after these behav events
% % (Note: need to put in catch for lack of events and something to make sure
% % that the wrong frames are not chosen in case I started the imaging after
% % I turned the lever on, by accident)
%
% % find the first frames following these events
%
%
% %% Incorrect rewarded stimuli
%
% %% Correct unrewarded stimuli
%
% %% Incorrect unrewarded stimuli
%
% %% Correct first contacts
%
% %% Incorrect first contacts
%
% %% all first contacts
%
% %% all rewards
%
% % for k = 2:length(endFrame)
% %
% %     rewardCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
% %     rewTif(:,:,1:(preFrame + postFrame +1),k) = tifStack(:,:,beginFrame(k):endFrame(k));
% %
% %     %plot(corrRewCa(:,k));
% %
% % end
% %
% % rewTifAvg = uint16(mean(rewTif, 4));
% %
% % % rewTifAvgDf = rewTifAvg.-tifAvg;
% %
% % for i = 1:size(rewTifAvg, 3)
% %     rewTifAvgDf = rewTifAvg(:,:,i)-tifAvg;
% %     imwrite(rewTifAvg(:,:,i), 'rewTifAvg.tif', 'writemode', 'append');
% % end
%
%
% %% all punishments
%
% %% all licks
%
% %% lever presses
%
% %% lever lifts
%
% %%
% % So, what else do I need to make?
% % - look at averages for:
% % - all stim
% % -
%
%     function eventEpochTool
%
%         for j=1:length(eventTimes)
%             zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
%         end
%
%         % then find indices of a window around the event
%         beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
%         okInd = find(beginFrame > 0 & beginFrame < numFrames);  % make sure indices are all positive
%         beginFrame = beginFrame(okInd); % and only take these
%         zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
%
%         endFrame = zeroFrame + postFrame;
%         okInd = find(endFrame > 0 & endFrame < numFrames); %
%         endFrame = endFrame(okInd);
%         zeroFrame = zeroFrame(okInd);   % just keep updated zeroFrames list for good measure
%
%         for k = 1:length(endFrame)
%
%             eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
%
% %             if roi == 1
% %                 for roiNum = 1:length(roiStruc)
% %                     roiDf = roiStruc(roiNum).roiDf;
% %                     ROIcorrFirstContactCa (:,roiNum,k)= roiDf(beginFrame(k):endFrame(k));
% %
% %                 end
% %             end
%
%             %plot(corrRewCa(:,k));
%
%         end
%
%         eventCaAvg = mean(eventCa, 2);
%
% %         if roi == 1
% %             ROIcorrFirstContactCaAvg = mean(ROIcorrFirstContactCa,3);
% %             ROIcorrFirstContactCaAvgAvg = mean(ROIcorrFirstContactCaAvg,2);
% %         end
%
%
%
% %         dendriteBehavStruc.corrRewCa  =  corrRewCa;
% %         dendriteBehavStruc.corrRewCaAvg  =  corrRewCaAvg;
%
% %         figure; plot(corrRewCaAvg); hold on;
% %         title('correct and incorrect rewarded trial whole frame Ca avgs');
%
%
%
%     end
%
% end
