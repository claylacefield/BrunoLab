function [whiskDataStruc] = convertOldWhiskData()

% this script converts old whisking data from the PhotonFocus camera (c. 2014)
% to the same data fields as the newer PS3eye camera


sessionDir = dir;
sessionDirNames = {sessionDir.name};

binName = sessionDir(find(cellfun(@length, strfind(sessionDirNames, '.bin')))).name;
baseName = binName(1:strfind(binName, '.bin')-1);
whiskAnalStrucName = sessionDir(find(cellfun(@length, strfind(sessionDirNames, 'whiskAnal')))).name;
load(whiskAnalStrucName);

sessionName = whiskAnalStrucName(1:14);

whiskDataStruc.meanAngle = -ma2;
whiskDataStruc.medianAngle = -med2;

whiskDataStruc.totalFr = length(time2);
whiskDataStruc.frTimes = time2'*1000;
whiskDataStruc.frameRate = round(1/(mean(diff(time2))));

whiskDataStruc.sessionPath = pwd;
whiskDataStruc.baseName = baseName;

save([sessionName '_whiskDataStruc_' date], 'whiskDataStruc');