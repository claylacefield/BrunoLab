function [frameTrig] = findFrameTrig(galvoSig, numFrames)

%% Find frames (signal #7;   NOTE: this detects the ends of respective frames)

% galvoSig = x2(7,:);

frameTimeout = 100; % round(1/fps*1000-(200/fps));

minSig = min(galvoSig);

galvoThresh = minSig/2; % *9/10;  % setting the thresh to 90% of min value

frameTrig = LocalMinima(galvoSig, frameTimeout, galvoThresh);
% Note: this works for 2Hz but need to check for 4Hz, and 
% for diff angle galvo signal


%% Adjust if number of frames from galvoSig is not same as those in TIF
%% stack

% this is a kludge because there are several reasons this could be true
% 1.) one or more imaging frames was dropped (which can occur in the
% ScanImage version we're using- not often, but can happen)
%       a.) sometimes the initial frame is dropped (late start)
%       b.) sometimes one or more frames are dropped in middle
% 2.) frame capture is stopped near the end of a framegrab, so the galvoSig
% is almost complete and is detected as a peak, but no frame data is saved
% 3.) maybe something else, I can't remember right now

if length(frameTrig) ~= numFrames
    
    %galvoAvMax = mean(galvoSig(frameTrig));
    %frameTrig = frameTrig(galvoSig(frameTrig)<(galvoAvMax + 0.1));  % this cleans up frame trigger times to prevent mistakes
    
    dTrig = diff(frameTrig);
    
    avDtrig = mean(dTrig);
    sdDtrig = std(dTrig);
    
    dThresh = avDtrig-4*sdDtrig; %6 
    
    % badTrigInd = find(dTrig < dThresh)+1;
    %
    % frameTrig(badTrigInd)=[];
    
    if dTrig(end) < dThresh
        frameTrig(end) = [];
    end
    
    dGalvo = [0 diff(galvoSig)];
    
    galvoOff = LocalMinima(-dGalvo, 1000, -3);
    
    % if no gavoOff signal then probably Labview aborted before framegrab
    if ~isempty(galvoOff)
        
        diffLastFrame = galvoOff - frameTrig(end);
        
        if diffLastFrame < 10
            frameTrig(end) = [];
        end
        
    end
    
end


if length(frameTrig) ~= numFrames
   galVals = galvoSig(frameTrig);
   avGalVals = mean(galVals);
   sdGalVals = std(galVals);
   frameTrig(galVals>(avGalVals+4*sdGalVals)) = [];
    
end