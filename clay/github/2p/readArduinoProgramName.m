function [programName] = readArduinoProgramName(txtFilename)

% This function quickly reads in a .TXT file and extracts the Arduino
% program name (NOTE: that the Arduino program names are not 100% accurate,
% i.e. they may represent an earlier version of the program when I did not
% properly update the Program name string after making changes)


% now read in the TXT file as a cell array
fullCell= textread(txtFilename,'%s', 'delimiter', '\n');   % read in whole file as cell array
%numEvents = length(fullCell)/2;

% now find the index of the first program name
% programNameInd = (find(strcmp(fullCell, 'Program name:'))+1);

try

for i = 1:length(fullCell)
    if strfind(fullCell{i}, 'Program name:')
        programNameInd = i+1;
    end
end

if ~exist('programNameInd')
    for i = 1:length(fullCell)
        if strfind(fullCell{i}, '_2p')
            programNameInd = i;
        end
    end
end


programName = fullCell{programNameInd};

catch
    disp('Cant find program name so must be older stage1');
    programName = 'stage1';
end

