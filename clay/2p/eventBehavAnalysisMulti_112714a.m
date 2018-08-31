function  [eventHistBehavStruc] = eventBehavAnalysisMulti(eventType, varargin)

%% USAGE: eventBehavAnalysisBatchHist(dataFileArray, eventType);
%% where 'eventType' is e.g. whiskContactTime1

% [ eventHistBehavStruc, rewTif ] = dendriteBehavAnalysis(nChannels, hz, avg, roi)
% Master script for looking at behavior-triggered average calcium signals

% batchEventHistStruc2hz, batchEventHistStruc4hz

% BATCH script
% reads info from 'dataFileArray' to load in all listed TIF stacks of
% imaging sessions and their corresponding BIN and TXT files
% and then calculates the event-triggered wholeframe calcium averages
% before saving them to the eventHistBehavStruc_(TIF filename) in the same
% folder
% AND
% concatenates all the data for each framerate for each mouse


% 102014
% making new script for processing data of any type based upon behavioral
% events
% 1.) varargin for filename or selecting .tif file
%       if varargin = 1, select bin file, specify signal type
%       if varargin = 2, specify signal and times, and select bin     
% 2.) objectivize analysis


if isempty(varargin) % if no input, then select a single .bin to analyze
    [filename, pathname] = uigetfile('*.bin', 'Select a .BIN file of behav signals to read');
    filepath = [pathname filename];

elseif length(varargin) == 1 % if one input, 
    
elseif length(varargin) == 2 % if two inputs, first is rowInd, second dataFileArray (for batch)
    rowInd = varargin{1};
    dataFileArray = varargin{2};
end




disp(['Processing ' filename]);

%% Detect behavioral event times from BIN file and event type indices from TXT
% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

disp('Detecting behavioral events');
tic;

%try

cd(pathname);

fileDir = dir;

for fileNum = 1:length(fileDir)
    if strmatch(fileDir.name, filename)
        
        binDatenum = fileDir(fileNum).datenum;
        
    end
end



%                             whiskSig1 = [];
%
%                             if strcmp(dataFileArray{rowInd, 16}, 'beam')
%
%                                 [eventStruc, whiskSig1] = detect2pEventsBatchWhisk(dataFileArray, rowInd);  % detect2pEvents(nChannels, sf);
%
%                                 whiskSig1 = whiskSig1 - runmean(whiskSig1, 20);
%
%                                 whiskSig1 = whiskSig1/max(whiskSig1);
%
%                                 frameTrig = 0:(length(whiskSig1)-1);
%
%                                 sf = 1000; % sample frequency of whisker signal
%
%                             elseif strcmp(dataFileArray{rowInd, 16}, 'video')
%                                 [eventStruc, whiskSig1] = detect2pEventsVidBatch(dataFileArray, rowInd);
%
%                                 totalMs = eventStruc.totalMs; %
%
%                                 whiskSig1 = whiskVideoProcBatch(dataFileArray, rowInd); % now load in whisker sig from video (usu 30fps)
%
%                                 sf = 30;
%                                 frameTrig = linspace(0, totalMs, length(whiskSig1)); % re-map times of whisker video frames
%                             end

% using Randy's function to make thresholded
% whisker signal for histogram (120413)

%                             whiskContacts1 = threshold(whiskSig1, 0.07, 8);
%                             whiskContacts2 = zeros(length(whiskContacts1),1);
%                             whiskContacts2(whiskContacts1) = 1;

% detect behavioral events (based upon .bin and .txt file nearest in time)
[eventStruc] = detect2pEventsSingle(binDatenum);  % detect2pEvents(nChannels, sf);
eventHistBehavStruc.eventStruc = eventStruc;  % just save this into output struc

% if want event to be from .bin, use eventType
histEventTimes = eventStruc.(eventType);
histEventBin = zeros(max(histEventTimes),1);
histEventBin(histEventTimes) = 1;

eventHistBehavStruc.eventType = eventType;
sf = 1000;

% go ahead and unpack these because we're going to use it many times
%                 frameTrig = eventStruc.frameTrig;
stimTrig = eventStruc.stimTrigTime;


%                 frameTrig = eventStruc.frameTrig; % unpack to trim frames if LabView stopped early

toc;


%% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

disp(['calculating event-triggered ' eventType ' histograms']);
tic;


fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names

% hz = dataFileArray{rowInd, 6};  % hz=fps;
%hz = 1000;

preFrame = 2*sf;    % number of frames to take before and after event time
postFrame = 6*sf;   % note that for whisker, sf is beam or video rate (1000 or 30)

% this loop unpacks all the structure fields into variables of the same name
for field = 1:length(fieldNames)
    
    if ~isempty(eventStruc.(fieldNames{field})) && (length(histEventTimes) > 1)
        
        % don't process stimTrig, frameTrig, and firstContactAbsT
        if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
            
            eventName = genvarname(fieldNames{field});
            
            % now construct the names of the event whiskSig signals
            eventNameEventBin = [eventName 'EventBin'];
            eventNameEventHist = [eventName 'EventHist'];
            
            % try/catch in case problem with some event
            % types
            %                                         try
            
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
            %                                             eventTimes = eventTimes(eventTimes > (histEventTimes(1)+2001) & eventTimes < (histEventTimes(end)-6001));
            eventTimes = eventTimes((eventTimes > 2001) & (eventTimes < (histEventTimes(end)-6001)));
            
            % eventEpochTool; % use subfunction to calculate event-trig whiskSig activ
            
            % for each event time, find the frame trigger index for the frame trig time closest to this
            %                                             for j=1:length(eventTimes)
            %                                                 zeroFrame(j) = eventTimes(j);
            % %                                                 zeroFrame(j) = find(histEventTimes >= eventTimes(j), 1, 'first');
            %
            % %                                                 [offsetTime, nearestFrameInd] = min(abs(histEventTimes - eventTimes(j)));
            % %
            % %                                                 zeroFrame(j) = nearestFrameInd;
            %
            %                                             end
            
            zeroFrame = eventTimes;
            
            numFrames = length(histEventBin);
            
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
            
            eventEventBin = []; % event-triggered binary event array (2D)
            
            % find avg whiskSig signal around each event
            
            for k = 1:length(eventTimes)
                try
                    % for frame avg whiskSig signal
                    eventEventBin(:,k) = histEventBin(beginFrame(k):endFrame(k));
                    
                    %plot(corrRewWhiskSig(:,k));
                    
                catch
                    disp(['Problem in processing event #' num2str(k) ' of type ' eventName]);
                end
                
            end
            
            %                             % now construct the names of the event whiskSig signals
            %                             eventNameEventBin = [eventName 'whiskSig'];
            %                             eventNameEventHist = [eventName 'WhiskSigAvg'];
            
            % and average over all events of a type
            %eventEventBinAvg = mean(eventEventBin, 2);
            
            % or for histogram 120513
            % sum of licks over all
            % instances of an event, div by
            % # that event
            
            eventEventHist = sum(eventEventBin,2)/size(eventEventBin,2);
            
            %eval([eventName ' = eventStruc.(fieldNames{field})']);
            
            % and put into structure for this day
            eventHistBehavStruc.(eventNameEventBin) = eventEventBin;
            eventHistBehavStruc.(eventNameEventHist) = eventEventHist;
            
            clear zeroFrame eventEventBin eventEventBinAvg;
            
            %                                         catch
            %                                             disp(['problem processing: ' eventName]);
            %                                             eventHistBehavStruc.(eventNameEventBin) = [];
            %                                             eventHistBehavStruc.(eventNameEventHist) = [];
            %                                         end
        end   % end IF field is StimInd or Times
        
    end     % end IF field isn't empty
end  % end FOR looking through all fields in eventStruc


% get tif file name
fn = filename(1:(strfind(filename, '.tif')-1));

cd(dayDir(b).name);

save([fn '_eventHistBehavStruc_' eventType '_' date], 'eventHistBehavStruc');

cd ..;
%clear tifStack;


%% plot output (and save graph)
%                 try
%                 plotDendBehavAnal(eventHistBehavStruc, fn, fps);
%
%                 hgsave([fn '_' date '.fig']);
%                 catch
%                     disp('cannot plot output graphs');
%                 end

toc;

%                 catch
%                     disp(['Error analyzing ' filename ', skipping file']);
%                 end

%clear eventHistBehavStruc;

