function [itiWhiskBoutCaStruc] = itiWhiskBoutCaFrame(toSave, toPlot) % dendriteBehavStruc, frameAvgDf, meanAngle, times)

%% USAGE: [eventCa, v, wPks] = itiWhiskBoutCaFrame(dendriteBehavStruc, frameAvgDf, mean_angle, times)

% So this is just reconstructed from the command history when I was trying
% to extract whisking bout-triggered calcium during "clean" ITIs


lockoutSec = 2;%0.75; %0.5; %1; %2 (old paper?);
sdThresh = 1;%0.75; %1 (old paper);%2; %1.5;
params.preBout = 500; %250 (old paper); %1000;
params.postBout = 2000;


%% Load in all necessary structures in session directory
% sessionDir = dir;
% sessionDirNames = {sessionDir.name};

fileTag = 'whiskDataStruc';
whiskDataStrucName = findLatestFilename(fileTag);
load(whiskDataStrucName);
sessionName = whiskDataStrucName(1:strfind(whiskDataStrucName, fileTag)-2);

fileTag = 'dendriteBehavStruc';
dbsName = findLatestFilename(fileTag);
load(dbsName);

% and load in the variables
frameAvgDf = dendriteBehavStruc.frameAvgDf;
meanAngle = whiskDataStruc.meanAngle; 
times = whiskDataStruc.frTimes;

try
frRate = whiskDataStruc.frameRate;
catch
    frRate = round(1000/mean(diff(times)));
end


if length(meanAngle)>length(times)
meanAngle = meanAngle(2:end);  % trim first point
end


% find end of calcium imaging session
eventStruc = dendriteBehavStruc.eventStruc;
frameTrig = eventStruc.frameTrig;
lastFrameTrigTime = frameTrig(end) + 500;

% calculate ca frame rate
imRate = 1000/mean(diff(frameTrig));

if imRate > 4 && imRate < 8 
    fps = 8;
elseif imRate < 4 && imRate > 2
    fps = 4;
elseif imRate <2
    fps = 2;
else
    disp('Weird frame rate');
end

%%
% correcting in case video went longer than LabView (like 2014-09-13-001)
%t = 1:size(x2, 2);  % length in ms of entire session (LabView sigs)
%timeMs = (time*1000);   % make whisk vid frame times in ms
timeMs = times;
tWhiskVidFrames = timeMs(timeMs < lastFrameTrigTime);  % cut off extra frame times
ma = -meanAngle(1:length(tWhiskVidFrames))';     % and whisk vid frames

%rma = runmean(ma, 10);

%figure; plot(ma); hold on; plot(rma, 'g');

%% Detect whisking bouts

% %ma = mean_angle;
% %frameTimes = times;
% %frameRate = 300;
% 
% % moving variance of mean whisker angle
% % using MATLABexchange function
v = movingvar(ma, 30); %50);

% v=v';
% sv = std(v);
% sdThresh = 2; % 2; pre 030515 = 1
% lockout = 300; % frameRate;  pre 030515 = 100
% wPks = LocalMinima(-v, lockout, -sdThresh*sv); % detect peaks
% NOTE: these are pk ind of whisker video frame times

%rv = runmean(v, 10); % 100);

ma2 = runmean(ma,30); % 3);
ma2 = ma2-runmean(ma2,1000);  % -mean(ma2);

%
ma2b = runmean(ma2, 60);
ma2bd = [0; diff(ma2b)];
ma2bdr = runmean(ma2bd, 30);
%std(ma2bdr);
ma4 = ma2bdr;

% disp('Filtering mean whisker angle');
% tic;
% ma3 = filtWhiskAngle(ma, frRate);
% toc;
% ma4 = [0; diff(ma3)];

%ma3 = ma2+v/2;
% ma4 = runmean([0; diff(ma3)], 20);

lockout = round(lockoutSec*frRate);%3*frRate; % 1000; 
%sdThresh = 1.5; %2; % 1;
%wPks = threshold(ma3, sdThresh*std(ma3), lockout); %rv
wPks = LocalMinima(-ma4, lockout, -sdThresh*std(ma4));

% rv2=rv; v2 = v;
% figure; plot(ma-mean(ma)); hold on; 
% plot(v2, 'c');
% plot(rv2, 'm');
% t2 = 1:length(rv);
% plot(t2(wPks), rv2(wPks), 'r.');

% t = 1:length(ma);
% figure; plot(ma); 
% hold on; plot(t(wPks), ma(wPks), 'r*');


%% Find clean ITI/stimTimes
% load in the relevant variables from calcium structure
%eventStruc = dendriteBehavStruc.eventStruc;
stimTrigTime = eventStruc.stimTrigTime;
rewTime4 = eventStruc.rewTime4; % random reward times

try
rewTime13 = eventStruc.rewTime13; % randRew no tone
rewTime4 = sort([rewTime4; rewTime13]);
catch
end

rewTime4 = rewTime4(rewTime4<stimTrigTime(end));

% look for indices of stimTrigTimes right after random rewards
%stimAfterRand = knnsearch(stimTrigTime, rewTime4); % these are stims beside (i.e. just after) random rewards
for numRew = 1:length(rewTime4)
    try
        stimAfterRand(numRew) = find(stimTrigTime>rewTime4(numRew),1);
    catch
    end  % have to try/catch because sometimes randRew at end?
end

rewItiInd = stimAfterRand-1;

try
    cleanStimInd = setxor(stimAfterRand, 1:length(stimTrigTime)); % these are ones that are not
catch
    cleanStimInd = 1:length(stimTrigTime);
end

% 011218
cleanStimInd = cleanStimInd(2:end); % I don't count the epoch before the first stim as an ITI

cleanItiInd = cleanStimInd-1; % because the clean/norew ITI will be the one BEFORE the clean stim ind

% load in stimTrigTime to find times of clean stims
%cleanItiInd = [];
%stimTrigTime = eventStruc.stimTrigTime;
%cleanStimTrigTime = stimTrigTime(cleanStimInd);


%% Now find whisking bouts during clean ITIs

% these are the times of whisking bout peaks
wPkTimes = tWhiskVidFrames(wPks);
itiWhiskBoutCaStruc.wPkTimes = wPkTimes;

%  broke this out into separate function
[whiskBoutCaStruc] = calcItiWhiskCa(cleanItiInd, timeMs, wPkTimes, dendriteBehavStruc, v, ma, params);

itiWhiskBoutCaStruc.itiWhiskPkTimes = whiskBoutCaStruc.itiWhiskPkTimes;
itiWhiskBoutCaStruc.itiWhiskZeroFrames = whiskBoutCaStruc.itiWhiskZeroFrames;
itiWhiskBoutCaStruc.itiWhiskBoutCa = whiskBoutCaStruc.itiWhiskBoutCa;
itiWhiskBoutCaStruc.itiWhiskBoutAngle = whiskBoutCaStruc.itiWhiskBoutAngle;
itiWhiskBoutCaStruc.itiWhiskBoutVar = whiskBoutCaStruc.itiWhiskBoutVar;
itiWhiskBoutCaStruc.params = params;
itiWhiskBoutCaStruc.params.lockout = lockout;
itiWhiskBoutCaStruc.params.sdThresh = sdThresh;

itiWhiskBoutCaStruc.caFps = fps;

clear whiskBoutCaStruc;

% now for randRew ITIs
% try
    [whiskBoutCaStruc] = calcItiWhiskCa(rewItiInd, timeMs, wPkTimes, dendriteBehavStruc, v, ma, params);
    
    itiWhiskBoutCaStruc.rewItiWhiskBoutCa = whiskBoutCaStruc.itiWhiskBoutCa;
    itiWhiskBoutCaStruc.rewItiWhiskBoutAngle = whiskBoutCaStruc.itiWhiskBoutAngle;
    itiWhiskBoutCaStruc.rewItiWhiskBoutVar = whiskBoutCaStruc.itiWhiskBoutVar;
% catch
%     
%     % save relavant variables to output structure
%     itiWhiskBoutCaStruc.rewItiWhiskBoutCa = [];
%     itiWhiskBoutCaStruc.rewItiWhiskBoutAngle = [];
%     itiWhiskBoutCaStruc.rewItiWhiskBoutVar = [];
%     
% end

path = pwd;
itiWhiskBoutCaStruc.caBasename = path(end-13:end);
itiWhiskBoutCaStruc.sessionName = sessionName;
txtName = dendriteBehavStruc.eventStruc.correctRespStruc.name;
itiWhiskBoutCaStruc.txtName = txtName;
% itiWhiskBoutCaStruc.lockout = lockout;
% itiWhiskBoutCaStruc.sdThresh = sdThresh;

itiWhiskBoutCaStruc.frameRate = frRate;
itiWhiskBoutCaStruc.fps = fps;

if toSave
save([sessionName '_itiWhiskBoutCaStruc_' date], 'itiWhiskBoutCaStruc');
end

% plot
if toPlot
    eventCa = itiWhiskBoutCaStruc.itiWhiskBoutCa;
eventWh = itiWhiskBoutCaStruc.itiWhiskBoutVar/1000;
eventWh2 = itiWhiskBoutCaStruc.itiWhiskBoutAngle/100-0.75;
%eventWh = eventWh(1:10:end);
%eventWh = (eventWh-mean(eventWh))/std(eventWh);

% eventWh = eventWh-mean(eventWh);
% eventWh2 = eventWh2-mean(eventWh2);
tCa1 = -2:0.25:6;

figure; plot(tCa1, eventCa);
title([txtName ' whisking bout triggered ca traces, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 
xlabel('sec');
ylabel('dF/F');
%figure; plot(mean(eventCa,2));

semCa = std(eventCa,0,2)/sqrt(size(eventCa,2));
semWh = std(eventWh,0,2)/sqrt(size(eventWh,2));
semWh2 = std(eventWh2,0,2)/sqrt(size(eventWh2,2));
tCa = linspace(-2,6, size(eventCa,1)); % linspace(1,size(eventWh,1), size(eventCa,1));
tWh = linspace(-2,6, size(eventWh,1));
figure; 
errorbar(tWh, mean(eventWh,2), semWh, 'r'); hold on;
errorbar(tWh, mean(eventWh2,2), semWh2, 'c');
errorbar(tCa, mean(eventCa,2), semCa);
title([txtName ' mean whisking bout triggered avg, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 
xlabel('sec');
ylabel('dF/F');
legend('whisk var', 'whisk angle', 'ca');
xlim([-2 6]);

figure; 
plot(tWh, mean(eventWh,2), 'r'); hold on;
plot(tWh, mean(eventWh2,2), 'c');
plot(tCa, mean(eventCa,2));
xlabel('sec');
ylabel('dF/F');
legend('whisk var', 'whisk angle', 'ca');
title([txtName ' mean whisking bout triggered avg, lock= ' num2str(lockout) ', ' num2str(sdThresh) 'sd thresh']); 
xlim([-2 6]);

end
