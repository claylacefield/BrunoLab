function [zeroFrame, eventCa , eventCaAvg] = eventTrigCa(filename, eventStruc, fps, frameAvgDf, field) %, tifStack2)

%
% this is basically a subfunction of dendriteBehavAnalysis
% (as of Fall 2014) that breaks out calculating behavioral 
% event-triggered calcium signals
% Thus you can make changes here (e.g. in the way that frames
% are aligned to event times) that are propagated to all scripts.




saveTif = 0;


stimTrig = eventStruc.stimTrigTime;
frameTrig = eventStruc.frameTrig;
fieldNames = fieldnames(eventStruc);
eventName = genvarname(fieldNames{field});

% if these are indices of trials, find corresponding times
if strfind(fieldNames{field}, 'StimInd')
    eventTimes = stimTrig(eventStruc.(fieldNames{field}));
elseif strfind(fieldNames{field}, 'Time')
    eventTimes = eventStruc.(fieldNames{field});
    %             else eventTimes = 0;
end

numFrames = length(frameTrig);

% only take event times that are within frame
% grab period (in case some things happen
% outside of this period, e.g. whisker hits)
eventTimes = eventTimes(eventTimes > (frameTrig(1)+2001) & eventTimes < (frameTrig(end)-6001));

% eventEpochTool; % use subfunction to calculate event-trig Ca activ

zeroFrame = [];

% for each event time, find the frame trigger index for the frame trig time closest to this
for j=1:length(eventTimes)
    %                                                 zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
    [offsetTime, nearestFrameInd] = min(abs(frameTrig - eventTimes(j)));
    zeroFrame(j) = nearestFrameInd;
end

preFrame = 2*fps;    % number of frames to take before and after event time
postFrame = 6*fps;

% then find frame indices of a window around the event
beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
okInd = find(beginFrame >= 0 & beginFrame < (numFrames-8*fps));  % make sure indices are all positive
beginFrame = beginFrame(okInd); % and only take these
zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list

endFrame = zeroFrame + postFrame;
okInd2 = find(endFrame >= 8*fps & endFrame < numFrames); %
endFrame = endFrame(okInd2);
zeroFrame = zeroFrame(okInd2);   % just keep updated zeroFrames list for good measure
beginFrame = beginFrame(okInd2);

eventFrames = [beginFrame endFrame];

eventCa = []; 

% find avg ca signal around each event

for k = 1:length(endFrame)
    try
        % for frame avg Ca signal
        eventCa(:,k) = frameAvgDf(beginFrame(k):endFrame(k));
        
        
    catch
        disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
    end
    
    
    %plot(corrRewCa(:,k));
    
%     if saveTif
%         
%         try
%             %                     % tifStack avg
%             if strcmp(eventName, 'rewStimStimInd')
%                 rewStimTif(:,:,:,k) = tifStack2(:,:,(beginFrame(k):endFrame(k)));
%             elseif strcmp(eventName, 'unrewStimStimInd')
%                 unrewStimTif(:,:,:,k) = tifStack2(:,:,(beginFrame(k):endFrame(k)));
%             end
%             
%             
%         catch
%         end
%         
%     end
    
end

%                             % now construct the names of the event ca signals
%                             eventNameCa = [eventName 'Ca'];
%                             eventNameCaAvg = [eventName 'CaAvg'];

% and average over all events of a type
eventCaAvg = mean(eventCa, 2);


fn = filename(1:(strfind(filename, '.tif')-1));


try
    
    stage1b = 0;
    
    if stage1b == 0
        rewStimTifAvg = uint16(squeeze(mean(rewStimTif, 4)));
        unrewStimTifAvg = uint16(squeeze(mean(unrewStimTif, 4)));
        %cd(tifPath);
        %                             if ~exist('rewStimTif.tif')
        for fr = 1:size(rewStimTifAvg, 3)
            imwrite(rewStimTifAvg(:,:,fr), [fn '_rewStimTif_' date '.tif'], 'writemode', 'append');
            imwrite(unrewStimTifAvg(:,:,fr), [fn '_unrewStimTif_' date '.tif'], 'writemode', 'append');
        end
        %                             end
    end     % end IF for stage1b = 0
    
catch
    %disp('WARNING: could not save rewStimTif');
end

