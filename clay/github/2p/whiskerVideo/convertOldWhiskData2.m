function [whiskDataStruc] = convertOldWhiskData2()

% this script converts old whisking data from the PhotonFocus camera (c. 2014)
% to the same data fields as the newer PS3eye camera

% extract whisker video frame times 
fileTag = 'whFrTimeStruc';
whTimeName = findLatestFilename(fileTag);
load(whTimeName);
basename = whTimeName(1:strfind(whTimeName, fileTag)-2);

whiskDataStruc.basename = basename;
whiskDataStruc.frTimes = whFrTimeStruc.frTimes;
whiskDataStruc.frameRate = round(1000/(mean(diff(whFrTimeStruc.frTimes))));

clear whFrTimeStruc;

% extract whisker angles measurements
fileTag = 'whiskMeasStruc';
whMeasName = findLatestFilename(fileTag);
load(whMeasName);

whiskDataStruc.meanAngle = -whiskMeasStruc.meanAngle;
whiskDataStruc.medianAngle = -whiskMeasStruc.medianAngle;
whiskDataStruc.totalFr = whiskMeasStruc.totalFr;

clear whiskMeasStruc;

save([basename '_whiskDataStruc_' date], 'whiskDataStruc');