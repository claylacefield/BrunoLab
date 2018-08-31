function [sessParams] = saveSessParams(layer, geno, somaDend)

% Function to input, extract, and save session parameters
% layer = '5' or '5b', e.g.
% geno = 'Rbp4', e.g.
% somaDend = 'soma' or 'dend'


path = pwd;
sessionName = path(end-13:end);

sessParams.sessionName = sessionName;

sessDir = dir;
sessionDirFilenames = {sessDir.name};

binName = sessionDirFilenames{find(cellfun(@length, strfind(sessionDirFilenames, '.bin')))};
baseName = binName(1:end-4);
sessParams.baseName = baseName;

txtFilename = [baseName '.txt'];
[programName] = readArduinoProgramName(txtFilename);
sessParams.programName = programName;

sessParams.path = path;

sessParams.layer = layer;
sessParams.geno = geno;
sessParams.somaDend = somaDend; 

save([sessionName '_sessParams'], 'sessParams');





