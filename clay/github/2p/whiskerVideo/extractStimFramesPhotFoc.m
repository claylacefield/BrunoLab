function [frTimes, frameRate, frTopAv,whFrTimeStruc] = extractStimFramesPhotFoc(filename, dendriteBehavStruc, saveMem)

% this script takes a whisker video MP4 from ps3eye, takes the avg pixel
% values for the top rows of each frame (where stim pole should appear) and
% detects dark transitions (i.e. when pole comes in)
% This is then compared with the rewStim times (from labView)

% NOTE: this only works for detection task at this time because it's
% looking for rewStimInd that correspond to stimuli, which will not work
% for top/bottom stim expts. I could address this later by reading in the
% task type from the TXT file.

% saveMem variable just changes the way MP4 files are loaded using extractStimFrames, which is
% slower I think, but doesn't take as much RAM

%errorCell = {};

%% Detect BOT stim times based upon whisker video

%topRange = 20;  % number of lines at top of frame to analyze for stim mov

try  % TRY/CATCH for problems, such as if stim isn't visible in frame, or if there is no stim (e.g. stage1)
    
    % load in times for bot/rewarded stim from dendriteBehavStruc
    stimTypeArr = dendriteBehavStruc.eventStruc.correctRespStruc.stimTypeArr;
    %     stimTimeArr = dendriteBehavStruc.eventStruc.correctRespStruc.stimTimeArr;
    stimTrigTime = dendriteBehavStruc.eventStruc.stimTrigTime;
    %     rewStimTimes = stimTimeArr(stimTypeArr == 1);
    rewStimTimes = stimTrigTime(stimTypeArr == 1) + 300;
    % NOTE: stimType for BOT stim is = 1
    %rewStimTimes = rewStimTimes + 250;
    
    %% Compute avg pix lum in area around stim (to see when bot stim is)
    
    %frTopAv = zeros(numWhVidFrames, 1);
    
    stimRange = [100 400; 300 640]; % [y1 x1; y2 x2];
    [frTopAv, frameRate] = stimAreaPixAv(filename, saveMem, stimRange, 1);
    
    
    % now find putative bottom stim times
    frTopAv = frTopAv-mean(frTopAv);
    frTopAv = runmean(frTopAv, 5);
    
    %save(frTopAv.mat, 'frTopAv');
    
    disp('Clearing video variables'); tic;
    clear vid;  % now just clear out big variables
    toc;
    
    % dvid = [0 diff(frTopAv)];
    
    % load in times for bot/rewarded stim from dendriteBehavStruc
    % NOTE: moved this to top so if no events, it fails and skips this session
    
    % now find the rewStim frames based upon the video (when bottom stim
    % enters frame) 
    sdThresh = 3/4;
    stimVidThresh = sdThresh*std(frTopAv);
    stimVidTimeout = 5*frameRate;
    pks = threshold(-frTopAv, stimVidThresh, stimVidTimeout); % detect frames when top luminance decreases (when stim comes in)
    
    pksMs = round(pks*1000/frameRate); % just estimate video stim times based upon framerate
    
    %rewStimTimes = stimTrigTime(rewStimInd);
    
    % 013116 adjust if some events cut off (sometimes cut off at beginning
    % if behavior starts too early, or at end if I don't stop behavior
    % correctly?)
    % IF number of video detected stim entries doesn't agree with number of
    % bottom stims (but if by too much, this might be other problem, such as if .TXT file is messed up, or if threshold for detecting video stim entries is too high)
    if length(pks) ~= length(rewStimTimes) && abs(length(pks)-length(rewStimTimes)) < 10
        
        % xcorr video times and rewStimTimes to get correct alignment 
        maxlag = 20;
        [val, ind] = max(xcorr(pksMs, rewStimTimes, maxlag));
        shift = ind - maxlag + 1;
        
        if shift < 3
            rewStimTimes = rewStimTimes((shift+1):end);
            errorCell = {'Adjusting stimTrig because some might have gotten cut off at beginning'};
            disp(errorCell{1});
        end
    end
    
    % NOTE: but just padding the initial cut off trials won't work here so have
    % to cut off the trials from the rewStimTime instead of padding
    
    numAttempts = 0;
    
    % and if you don't get the right number of stim events, change thresh and
    % start over
    while length(rewStimTimes) ~= length(pks) && numAttempts <= 10
        
        if length(rewStimTimes) < length(pks)
            disp('Too many stimVid peaks, so increasing thresh');
            sdThresh = sdThresh*2;
            stimVidThresh = sdThresh*std(frTopAv);
            stimVidTimeout = 6*frameRate;
            pks = threshold(-frTopAv+mean(frTopAv), stimVidThresh, stimVidTimeout);
            
            numAttempts = numAttempts + 1;
            
        elseif length(rewStimTimes) > length(pks)
            disp('Too few stimVid peaks, so decreasing thresh');
            sdThresh = sdThresh/3;
            stimVidThresh = sdThresh*std(frTopAv);
            stimVidTimeout = 4*frameRate;
            pks = threshold(-frTopAv+mean(frTopAv), stimVidThresh, stimVidTimeout);
            
            numAttempts = numAttempts + 1;
        end
        
        
    end
    
    
    if length(rewStimTimes) == length(pks)
        
        
        %% Calculate whisker video frame times for all frames
        
        % okay, so ps3eye may drop frames at high speeds, so need to adjust frame
        % times to account for this. Do this by creating linearly spaced frame
        % times between each rewStimTime
        disp('Calculating frame times...'); tic;
        frTimes = zeros(length(frTopAv),1);
        frTimes(pks) = rewStimTimes;
        
        singFrMs = 1000/frameRate;
        
        for i = 1:length(rewStimTimes)-1
            
            %epRange =  1:rewStimTimes(i);
            tAdj = round(linspace(rewStimTimes(i)+singFrMs, rewStimTimes(i+1)-singFrMs, pks(i+1)-pks(i)-1));
            frTimes(pks(i)+1:pks(i+1)-1) = tAdj;
            
        end
        
        % NOTE: this works for all frames between first and last rewStim start, but
        % still need to fix this for first and last epochs
        
        %% Now find frame times for initial and final epochs
        
        % find average framerate for first and last epochs
        rate1 = (pks(2)-pks(1))/(rewStimTimes(2)-rewStimTimes(1));
        rate2 = (pks(end)-pks(end-1))/(rewStimTimes(end)-rewStimTimes(end-1));
        
        % use this to find frame times for first/last epochs
        t0 = rewStimTimes(1)-(pks(1)-1)/rate1;
        times1 = round(t0:1/rate1:(rewStimTimes(1)-1/rate1));
        
        % final epoch
        tEnd = rewStimTimes(end)+(length(frTimes)-pks(end))/rate2;
        times2 = round((rewStimTimes(end)+1/rate2):1/rate2:tEnd);
        
        % now just fill in the whisker video frame times for the initial and final epochs
        frTimes(1:(pks(1)-1)) = times1;
        frTimes((pks(end)+1):end) = times2;
        toc;
        
    else
        disp('Getting wrong number of rew trials from whisker video, so not processing');
    end
    
    whFrTimeStruc.filename = filename;
    whFrTimeStruc.frTimes= frTimes;
    whFrTimeStruc.frameRate= frameRate;
    whFrTimeStruc.frTopAv= frTopAv;
    %whFrTimeStruc.errorCell= errorCell;
    
    basename = filename(1:strfind(filename, '.mp4')-1);
    whFrTimeStruc.basename = basename;
    
    save([basename '_whFrTimeStruc_' date '.mat'], 'whFrTimeStruc');
    
catch
    disp('Problem calculating frameTimes for this file');
    
end
