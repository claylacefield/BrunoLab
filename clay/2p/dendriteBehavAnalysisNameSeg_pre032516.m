function dendriteBehavAnalysisNameSeg(filename, dayPath, seg, toProcess, saveTif)

toPlot = 0;
%toProcess = 0;

filename = filename(1:(strfind(filename, '.tif')+3));

tifBasename = filename(1:(strfind(filename, '.tif')-1));



% go to tif folder
cd([dayPath '/' tifBasename]);

tifDir = dir;

tifDirFilenames = {tifDir.name};

if isempty(find(cellfun(@length, strfind(tifDirFilenames, 'dendriteBehavStruc')))) && isempty(find(cellfun(@length, strfind(tifDirFilenames, '_seg_')))) && ~isempty(find(cellfun(@length, strfind(tifDirFilenames, '.txt'))))

toProcess = 1;
end

% put in 022616 to reprocesses stage1 data to allow whisker video proc
if toProcess == 2 && ~isempty(find(cellfun(@length, strfind(tifDirFilenames, '.txt'))))
   txtName = tifDir(find(cellfun(@length, strfind(tifDirFilenames, '.txt')))).name; 
   programName = readArduinoProgramName(txtName);
   if strfind(programName, 'stage')
       toProcess = 1;
   end
end

if toProcess == 1
%try
%                 cd(dayDir(b).name);  % NO, stay in the day folder
%                 % tif directory

disp(['Processing ' filename]);


%toc;


%% Import the image stack

%filename = [dayDir(b).name '.tif'];
tifpath = [dayPath '/' tifBasename '/' filename]; %[dayDir(b).name '.tif']];
% NOTE: build the tifpath different because of the extra
% folder layer for motion correction

disp(['Processing image stack for ' filename]);
tic;

% see how big the image stack is
stackInfo = imfinfo(tifpath);  % create structure of info for TIFF stack
sizeStack = length(stackInfo);  % no. frames in stack
width = stackInfo(1).Width; % width of the first frame (and all others)
height = stackInfo(1).Height;  % height of the first frame (and all others)

clear stackInfo;    % clear this because it might be big
toc;

% extract number of imaging channels and only take green for
% Ca++ activity
%                 numImCh = dataFileArray{rowInd, 11};

% NOTE: took prev. out because manually removed other chan
numImCh = 1;

% this is to preallocate tifstack for speed
numFrames = length(1:numImCh:sizeStack);
%tifStack = zeros(width, height, numFrames);

%% Detect behavioral event times from BIN file and event type indices from TXT
% select behavior signal BIN file and behavior event TXT file
% and extract times of particular events

disp('Detecting behavioral events');
tic;

%cd(dayPath);

errorNum = 0;
errorCell = {};

dendriteBehavStruc.filename = filename;
% must find filenames to operate on (e.g.
% 150517_mouseR141a)

%tifDirFilenames = {tifDir.name};

binInd = find(cellfun(@length, strfind(tifDirFilenames, '.bin')));  % get dir indices of .txt files
binFilename = tifDir(binInd).name;

sessBasename = binFilename(1:strfind(binFilename, '.bin')-1);

programName = readArduinoProgramName([sessBasename '.txt']);

if isempty(strfind(programName, 'stage'))
disp(['Detecting behavioral events for ' filename]); tic;
%[eventStruc, x2] = detect2pEventsSingleName(sessBasename, numFrames); toc;
[eventStruc] = detect2pEventsNameNew(sessBasename, numFrames);

eventStruc = findStimOrder(eventStruc);

toc;
else
    disp('Using stage1 event detection');
    eventStruc = detect2pEventsNameStage1New(sessBasename, numFrames);
end

frameTrig = eventStruc.frameTrig; % unpack to trim frames if LabView stopped early

%toc;

% 051214: fix for bad frame initiation
% Because sometimes ScanImage balks when
% capturing the first few frames (reason
% unknown, but may be callback problem) yet
% there are still frameTrigs, so trim first few
% to size of tif stack (=numFrames)

%                         if length(frameTrig)>numFrames
%                             frameTrig = frameTrig(((length(frameTrig)-numFrames)+1):end);
%                             disp('More frameTrig than tif frames so cutting out first few galvo trigs...');
%                             errorNum = errorNum + 1;
%                             errorCell{errorNum} = 'More frameTrig than tif frames so cutting out first few galvo trigs...';
%                         end

%eventStruc.frameTrig = frameTrig;

dendriteBehavStruc.eventStruc = eventStruc;

basename = tifBasename; % filename(1:(strfind(filename, '.tif')-1));


%saveTif = 1;
disp(['Reading in TIF stack for ' filename]);
tic;
[tifStack2] = readTifStack(filename, sizeStack, numImCh, saveTif);
toc;

cd([dayPath '/' tifBasename]);  % dayDir(b).name]);

disp(['# frames in tifStack = ' num2str(size(tifStack2,3))]);

%tifStack = tifStack(:,:, 1:length(frameTrig));  % trim frames for which there is no LabView signal

tifAvg = uint16(mean(tifStack2, 3)); % calculate the mean image (and convert to uint16)

%numFrames = size(tifStack, 3);

%% Calculate ROI profiles
% select ImageJ ROI Manager MultiMeasure TXT file
% and extract timecourses of calcium activity
% NOTE: select all ROIs first, then whole frame avg

avg = 0; roi = 0; % specify wheter to process frame mean profile and ROI profiles

%                 if avg == 1 || roi == 1
%                     [roiStruc, frameAvgDf] = dendriteProfiles(numFrames, avg, roi);
%                 end

if avg == 0
    frameAvg = mean(mean(tifStack2,1),2);  % take average for each frame
    frameAvg = squeeze(frameAvg);  % just remove singleton dimensions
    % frameAvg = frameAvg - mean(frameAvg, 1);    % just subtract mean
    
    % now doing this with the running mean (runmean from Matlab
    % Cntrl)
    
    runAvg = runmean(frameAvg, 100);    % using large window to get only shift in baseline
    
    frameAvgDf = (frameAvg - runAvg)./runAvg;
    
    % figure; plot(frameAvgDf);
end

%toc;

if seg == 1
    
    basename = filename(1:(strfind(filename, '.tif')-1));
    cd([dayPath '/' basename]);
    
    tifDir = dir;
    
    prevSeg = 0;
    
    C = [];
    
    
    % find tifDir indices of seg2 files
    segInd = find(cellfun(@length, strfind({tifDir.name}, 'seg2')));
    %             if filterDate ~= 0
    %                 filterInd = find(cellfun(@length, strfind({tifDir.name}, filterDate)));
    %                 segInd = intersect(segInd, filterInd);
    %             end
    
    % find the latest seg2 file index
    segDatenums = [tifDir(segInd).datenum];
    [lsaMax, latSegArrInd] = max(segDatenums);
    latestSegInd = segInd(latSegArrInd);
    
    
    % load in this segStruc
    %     for d = 3:length(tifDir)
    %         if (~isempty(strfind(tifDir(d).name, 'seg')) && prevSeg == 0)
    disp(['loading in previously segmented file: ' tifDir(latestSegInd).name]);
    load(tifDir(latestSegInd).name);
    C = segStruc.C;
    prevSeg = 1;
    
    
else
    C = [];
end

%% make histogram of Ca events for each seg

%fps = dataFileArray{rowInd, 6};

% determine fps empirically based upon frameTrig
empFps = 1000*1/mean(diff(frameTrig));

if empFps >= 5
    fps = 8;
elseif empFps <5 && empFps >=2
    fps = 4;
elseif empFps < 2 && empFps>0
    fps = 2;
end

if ~isempty(C)
    
    [segStruc] = detectAllSegPks(segStruc, fps);
    
end

%% And tabulate indices of behavioral event types
% (Extract values from behavioral event structure)
% find the times of frames and do timecourse average based upon those times

disp('Calculating event-triggered frame Ca avg');
tic;


% put this in to limit frames to number of frame triggers
% from galvo (in case I stopped labview before scanimage)
% OR vice versa if there is an extra detected frame trigger

if length(frameAvgDf) > length(frameTrig)
    frameAvgDf = frameAvgDf(1:length(frameTrig));
    if ~isempty(C)
        C = C(1:length(frameTrig), :);
    end
    errorNum = errorNum + 1;
    errorCell{errorNum} = 'More frames than frameTrig so trimming these off (labview stopped too early)';
elseif length(frameTrig) > length(frameAvgDf)
    %frameTrig = frameTrig(1:length(frameAvgDf));
    
    frameTrig = round(linspace(frameTrig(1), frameTrig(end), numFrames));
    eventStruc.frameDrop = length(frameTrig)-numFrames;
    disp('Dropped frames so adjusting frameTrigs to length of frames');
    
    errorNum = errorNum + 1;
    errorCell{errorNum} = 'More frameTrig than frames, so trimming frameTrig (WARNING: might have dropped frames)';
    % NOTE: may be better to adjust time another way
    
end

eventStruc.frameTrig = frameTrig;
dendriteBehavStruc.frameAvgDf = frameAvgDf;
dendriteBehavStruc.errorCell = errorCell;

fieldNames = fieldnames(eventStruc);    % generate cell array of eventStruc field names

%                             fps = dataFileArray{rowInd, 6};
%                             fps=fps;

%                     preFrame = 2*fps;    % number of frames to take before and after event time
%                     postFrame = 6*fps;

% this loop unpacks all the structure fields into variables of the same name
for field = 1:length(fieldNames)
    
    if ~isempty(eventStruc.(fieldNames{field}))
        
        % don't process stimTrig, frameTrig, and firstContactAbsT
        if (~isempty(strfind(fieldNames{field}, 'StimInd')) || ~isempty(strfind(fieldNames{field}, 'Time')))
            
            eventName = genvarname(fieldNames{field});
            
            % now construct the names of the event ca signals
            eventNameCa = [eventName 'Ca'];
            eventNameCaAvg = [eventName 'CaAvg'];
            eventNameRoiHist = [eventName 'RoiHist'];
            eventNameRoiHist2 = [eventName 'RoiHist2'];
            
            eventNameFrInds = [eventName 'FrInds'];
            
            % try/catch in case problem with some event
            % types
            try
                %fps = fps;
                
                if ~isempty(C)
                    
                    [zeroFrame, eventCa , eventCaAvg, segEventCa, eventRoiHist, eventRoiHist2] = eventTrigCaRoiPk(filename, eventStruc, fps, segStruc, frameAvgDf, field, tifStack2);
                    
                    segEventCaAvg = mean(segEventCa, 3);
                    segStruc.(eventNameCa) = segEventCa;
                    segStruc.(eventNameCaAvg) = segEventCaAvg;
                    segStruc.fps = fps;
                    segStruc.(eventNameRoiHist)= eventRoiHist;
                    segStruc.(eventNameRoiHist2)= eventRoiHist2;
                else
                    [zeroFrame, eventCa , eventCaAvg] = eventTrigCa(filename, eventStruc, fps, frameAvgDf, field, tifStack2);
                    
                    
                end
                
                
                %eval([eventName ' = eventStruc.(fieldNames{field})']);
                
                % and put into structure for this day
                dendriteBehavStruc.(eventNameCa) = eventCa;
                dendriteBehavStruc.(eventNameCaAvg) = eventCaAvg;
                
                % 081114 record trigger frames
                % for each event type
                dendriteBehavStruc.(eventNameFrInds) = zeroFrame;
                
                
                if saveTif == 1
                    try
                        
                        %                     % tifStack avg
                        if strcmp(eventName, 'rewStimStimInd') || strcmp(eventName, 'unrewStimStimInd')
                            disp(['Making avg TIF stack for ' eventName]); tic;
                            for numEvent = 1:length(zeroFrame)
                                frRange = (zeroFrame(numEvent)-2*fps):(zeroFrame(numEvent)+6*fps);
                                if strcmp(eventName, 'rewStimStimInd')
                                    %disp('Compiling rewStimTif avg');
                                    rewStimTif(:,:,:,numEvent) = tifStack2(:,:,frRange);
                                elseif strcmp(eventName, 'unrewStimStimInd')
                                    %disp('Compiling unrewStimTif avg');
                                    unrewStimTif(:,:,:,numEvent) = tifStack2(:,:,frRange);
                                end
                            end
                            toc;
                        end
                    catch
                        %disp('Could not process rewStimTif frame avg');
                    end
                end
                
                
                clear zeroFrame eventCa eventCaAvg eventRoiHist eventRoiHist2;
                
            catch
                disp(['problem processing: ' eventName]);
                dendriteBehavStruc.(eventNameCa) = [];
                dendriteBehavStruc.(eventNameCaAvg) = [];
            end
        end
        
    end     % end IF for ~isempty fieldname
end     % end FOR loop for all fieldnames

% get tif file name
fn = filename(1:(strfind(filename, '.tif')-1));

if saveTif
    disp('Saving stim avg TIF stacks'); tic;
    try
        
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
        disp('WARNING: could not save rewStimTif');
    end
    toc;
    %                             dendriteBehavStruc.rewStimTifAvg = rewStimTifAvg;
    %                             dendriteBehavStruc.unrewStimTifAvg = unrewStimTifAvg;
    clear rewStimTif unrewStimTif rewStimTifAvg unrewStimTifAvg; % tifStack2;
    % cd ..;
end

%         % and just save list of filenames in batch struc
%         if fps == 2
%             num2hzFiles = num2hzFiles + 1;
%             batchDendStruc2hz.name{num2hzFiles} = fn;
%         elseif fps == 4
%             num4hzFiles = num4hzFiles + 1;
%             batchDendStruc4hz.name{num4hzFiles} = fn;
%         elseif fps == 8
%             num8hzFiles = num8hzFiles + 1;
%             batchDendStruc8hz.name{num8hzFiles} = fn;
%         end


% now just save the output structure for this session in this directory
disp('Saving segStruc');
try
    save([fn '_seg_' date '.mat'], 'segStruc');
    clear segStruc;
catch
    disp('no segStruc');
end

save([fn '_dendriteBehavStruc_' date], 'dendriteBehavStruc');

clear tifStack tifStack2; % dendriteBehavStruc;




%% plot output (and save graph)

if toPlot
    try
        plotDendBehavAnal2(dendriteBehavStruc, fn, fps);
        
        hgsave([fn '_summGraphs_' date '.fig']);
    catch
        disp('cannot plot output graphs');
    end
end

toc;

%                 catch
%                     disp(['Error analyzing ' filename ', skipping file']);
%                 end

clear dendriteBehavStruc;

% catch
%     disp('Problem processing this file, so didnt save anything');
% end

else
    disp(['Found previous dendriteBehavStruc and segStruc for ' filename ' so skipping...']);

end