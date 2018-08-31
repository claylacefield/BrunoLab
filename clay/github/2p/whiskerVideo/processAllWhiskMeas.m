function processAllWhiskMeas(sessionNames) % , rewStimFrames)

% clay 2015
% This script is to
% go through all measurements and extract whisker angles and frame times
% for whisker video from PhotonFocus camera in Sep. 2014

% 2016
% This is to be done in a folder with all whisk data and measurements from
% the files in Fall 2014 (R135, R131)



for sessInd = 1:length(sessionNames)
    sessName = sessionNames{sessInd};
    
    disp(['Loading ' sessName '.measurements']);
    tic;
    measurements = LoadMeasurements([sessName '.measurements']);
    toc;
    %disp('Removing extraneous measurements fields to save memory');
    %measurements = rmfield(measurements, 'wid');
    %measurements = rmfield(measurements, 'label');
    %measurements = rmfield(measurements, 'face_x');
    %measurements = rmfield(measurements,'face_y');
    %measurements = rmfield(measurements, 'score');
    %measurements = rmfield(measurements, 'curvature');
    %measurements = rmfield(measurements, {'wid' 'label' 'face_x' 'face_y' 'score' 'curvature'});
    
    
    disp('Extracting mean/median whisker angles');
    tic;
    [meanAngle, medianAngle, totalFr, whiskerInfo] = extractBestWhiskerAngles(measurements, 150);
    toc;
    
%     load([sessName '_rewStimAdjTime.mat']);
%     disp(['Loading ' sessName '_rewStimAdjTime.mat and calculating video frame times']);
%     tic;
%     [times, frRate] = calcWhiskFrameTimes(totalFr, rewStimAdjTime, rewStimFrames, sessInd);
%     toc;

    load([sessName '_whiskData.mat']);
    
    disp('Saving...');
    save([sessName '_whiskData_' date '.mat'], 'meanAngle', 'medianAngle', 'totalFr', 'times', 'frRate', 'whiskerInfo');


end



