function [filename] = findLatestFilename(fileTag)

% This function returns the filename for the most recent file whose name
% contains fileTag

% INPUT: fileTag = string in filenames to check

currDir = dir;

dirFilenames = {currDir.name};

fileTypeInd = find(cellfun(@length, strfind(dirFilenames, fileTag)));

%             if filterDate ~= 0
%                 filterInd = find(cellfun(@length, strfind({tifDir.name}, filterDate)));
%                 segInd = intersect(segInd, filterInd);
%             end

% find the latest file index
fileDatenums = [currDir(fileTypeInd).datenum];
[maxDatenum, latestInd] = max(fileDatenums);
latestDirInd = fileTypeInd(latestInd);

filename = currDir(latestDirInd).name;