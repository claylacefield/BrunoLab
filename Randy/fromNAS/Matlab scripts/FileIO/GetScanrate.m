function [scanrate] = GetScanrate(filepath)

% Determine the sampling rate
%
% Randy, September 2014

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK)
        return; end
    filepath = [pathname, filename];
end

fid = fopen(filepath, 'r', 'b');
if (fid == -1) error('could not open file for reading'); end

scanrate = ReadHeaderField(fid, 'scan rate');
scanrate = str2num(scanrate);

fclose(fid);