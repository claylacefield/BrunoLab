function [unitItiWhiskCa] = itiWhiskBoutCaUnit(itiWhiskBoutCaStruc);

disp('Processing unitItiWhiskCa');
tic;
segName = findLatestFilename('_seg_');
load(segName);

goodSegName = findLatestFilename('_goodSeg_');
load(goodSegName);

zeroFrame = itiWhiskBoutCaStruc.itiWhiskZeroFrames;

fps = 4;
preFrame = 2*fps;    % number of frames to take before and after event time
postFrame = 6*fps;

% then find frame indices of a window around the event
beginFrame = zeroFrame - preFrame;  % find index for pre-event frame
endFrame = zeroFrame + postFrame;


for i = 1:length(goodSeg)
    segCa =  segStruc.C(:,i);
    eventCa = [];
    
    % find avg ca signal around each event
    
    for k = 1:length(endFrame)
        try
            % for frame avg Ca signal
            eventCa(:,k) = segCa(beginFrame(k):endFrame(k));
        catch
            disp(['Problem in processing event #' num2str(k)]); % ' of type ' eventName]);
        end
    end
    unitItiWhiskCa(:,:,i) = eventCa;
end
toc;