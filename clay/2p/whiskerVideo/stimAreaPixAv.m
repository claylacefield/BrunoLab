function [frTopAv, frameRate] = stimAreaPixAv(filename, saveMem, stimRange, toSave)

% Clay 2016
% This script is for computing the avg pixel luminosity in the area
% surrounding the stimulus (for aligning whisker video frames)

disp('Opening MP4 with VideoReader class'); tic;
vob = VideoReader(filename); toc;
%width = vob.width;
%height = vob.height;
frameRate = 300; %vob.FrameRate; % 010317 not giving correct framerate for some reason
numWhVidFrames = vob.NumberOfFrames;

if saveMem == 0 % to load in entire video (faster but more mem)
    
    disp(['Reading entire video for ' filename ' (takes more RAM)']); tStart = tic;
    vid = read(vob); toc(tStart); % load in video (NOTE: having prob with readFrame on server)
    clear vob;
    
    disp('Extracting top whisker video lines and compressing RGB'); tStart = tic;
    vid = vid(stimRange(1):stimRange(2),stimRange(3):stimRange(4),:,:);
    vid = squeeze(mean(vid,3)); toc(tStart);
    
    disp('Computing average pixel lum for area around stim'); tStart = tic;
    frTopAv = [];
    for frNum = 1:size(vid, 3)
        frame = vid(:,:,frNum);  % take mean of 3 channels (RGB)
        fr = frame(:);  % just linearize
        frTopAv(frNum) = mean(fr);  % and take the average value
    end
    toc(tStart);
    
else  % or process video frame-by-frame to save mem
    
    disp(['Reading ' filename ' video frame by frame']);
    
    disp('Computing average pixel lum for area around stim'); tStart = tic;
    frTopAv = [];
    
    firstFrame = read(vob,1);  % load in first frame
    
    for frNum = 1:numWhVidFrames
        if mod(frNum, 1000) == 0
            disp(['frame ' num2str(frNum) ' out of ' num2str(numWhVidFrames)]);
        end
        
        frame = read(vob, frNum);
        difFr = frame-firstFrame;
        if sum(abs(difFr(:)))>10000000
            disp('Big jump in frame so stop loading');
            break;
        end
        
        frame = squeeze(mean(frame,3));  % take mean of 3 channels (RGB)
        lines = frame(stimRange(1):stimRange(2),stimRange(3):stimRange(4));
        lines = lines(:);  % just linearize
        frTopAv(frNum) = mean(lines);  % and take the average value
    end
    
    toc(tStart);
    
end

clear vob;

if toSave == 1
    basename = filename(1:strfind(filename, '.mp4')-1);
    save([basename '_frTopAvRaw_' date '.mat'], 'frTopAv', 'stimRange', 'frameRate');
end