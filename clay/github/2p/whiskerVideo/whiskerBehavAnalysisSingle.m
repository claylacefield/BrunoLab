function  [whiskBehavStruc, eventStruc, x2] = whiskerBehavAnalysisSingle(whiskSig, time)

% USAGE:[whiskBehavStruc, eventStruc, x2] = whiskerBehavAnalysisSingle(whiskSig, time);
%
% This script is to analyze the behavioral event-triggered whisker angle 
% signals that Chris extracts from the high-speed video
% NOTE: this doesn't at this time process the whisker angle signals,
% so you must do this when constructing the whiskSig variable if desired



frameNum = 0;

% if nargin < 1
[filename, pathname] = uigetfile('*.bin', 'Select a .BIN file that goes with this whisker data');
filepath = [pathname filename];
% end

mouseBase = filename(1:strfind(filename, '.bin')-1);

cd(pathname);

currDir = dir;

fileInd = find(strcmp(filename, {currDir.name}));

tifDatenum = currDir(fileInd).datenum;  % use acq to find .bin and .txt files

[eventStruc, x2] = detect2pEventsSingle(tifDatenum, 8); %nChannels,1000);  % detect2pEvents(nChannels, sf);

whiskBehavStruc.eventStruc = eventStruc;

whiskSig1 = whiskSig;

whiskBehavStruc.whiskSig = whiskSig;

%% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

disp('calculating event-triggered whiskSig1 avg');
tic;

fieldNames = {};

fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names

%hz = dataFileArray{rowInd, 6};  % hz=fps;
hz = 300; sf = 300;

frameTrig = round(time*1000);

preFrame = 2*sf;    % number of frames to take before and after event time
postFrame = 6*sf;   % note that for whisker, sf is beam or video rate (1000 or 30)

% this loop unpacks all the structure fields into variables of the same name
for field = 1:length(fieldNames)
    
    if ~isempty(eventStruc.(fieldNames{field}))
        
        % don't process stimTrig, frameTrig, and firstContactAbsT
        if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
            
            eventName = genvarname(fieldNames{field});
            
            % now construct the names of the event whiskSig signals
            eventNameWhiskSig = [eventName 'WhiskSig'];
            eventNameWhiskSigAvg = [eventName 'WhiskSigAvg'];
            
            % try/catch in case problem with some event
            % types
            try
                
                stimTrig = eventStruc.stimTrigTime;
                
                % if these are indices of trials, find corresponding times
                if strfind(fieldNames{field}, 'StimInd')
                    eventTimes = stimTrig(eventStruc.(fieldNames{field}));
                elseif strfind(fieldNames{field}, 'Time')
                    eventTimes = eventStruc.(fieldNames{field});
                    %             else eventTimes = 0;
                end
                
                % only take event times that are within frame
                % grab period (in case some things happen
                % outside of this period, e.g. whisker hits)
                eventTimes = eventTimes(eventTimes > (frameTrig(1)+2001) & eventTimes < (frameTrig(end)-6001));
                
                % eventEpochTool; % use subfunction to calculate event-trig whiskSig activ
                
                % for each event time, find the frame trigger index for the frame trig time closest to this
                for j=1:length(eventTimes)
                    %                                                 zeroFrame(j) = eventTimes(j);
                    zeroFrame(j) = find(frameTrig >= eventTimes(j), 1, 'first');
                    
                end
                
                numFrames = length(frameTrig);
                
                % then find frame indices of a window around the event
                beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
                okInd = find(beginFrame >= 0 & beginFrame <= (numFrames-8*sf));  % make sure indices are all positive
                beginFrame = beginFrame(okInd); % and only take these
                zeroFrame = zeroFrame(okInd);   % and strip out all the bad ones from the zeroFrame list
                
                endFrame = zeroFrame + postFrame;
                okInd2 = find(endFrame >= 8*sf & endFrame <= numFrames); %
                endFrame = endFrame(okInd2);
                zeroFrame = zeroFrame(okInd2);   % just keep updated zeroFrames list for good measure
                beginFrame = beginFrame(okInd2);
                
                eventWhiskSig = [];
                
                % find avg whiskSig signal around each event
                
                for k = 1:length(eventTimes)
                    try
                        % for frame avg whiskSig signal
                        eventWhiskSig(:,k) = whiskSig1(beginFrame(k):endFrame(k));
                        
                        %plot(corrRewWhiskSig(:,k));
                        
                    catch
                        disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
                    end
                    
                end
                
                %                             % now construct the names of the event whiskSig signals
                %                             eventNameWhiskSig = [eventName 'whiskSig'];
                %                             eventNameWhiskSigAvg = [eventName 'WhiskSigAvg'];
                
                % and average over all events of a type
                eventWhiskSigAvg = mean(eventWhiskSig, 2);
                
                %eval([eventName ' = eventStruc.(fieldNames{field})']);
                
                % and put into structure for this day
                whiskBehavStruc.(eventNameWhiskSig) = eventWhiskSig;
                whiskBehavStruc.(eventNameWhiskSigAvg) = eventWhiskSigAvg;
                
                clear zeroFrame eventWhiskSig eventWhiskSigAvg;
                
            catch
                disp(['problem processing: ' eventName]);
                whiskBehavStruc.(eventNameWhiskSig) = [];
                whiskBehavStruc.(eventNameWhiskSigAvg) = [];
            end
        end
        
    end
end

% get tif file name
fn = filename(1:(strfind(filename, '.tif')-1));

% now just save the output structure for this session in this directory


% save([fn '_whiskBehavStruc_' date], 'whiskBehavStruc');



toc;


