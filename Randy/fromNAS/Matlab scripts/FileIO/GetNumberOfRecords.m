function nrecs = GetNumberOfRecords(filepath, duration)

% Count the # of records in a .dat file generated by ntrode.vi
%
% Randy Bruno, October 2003

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) 
        return; end
    filepath = [pathname, filename];
end

if (nargin < 2)
    duration = input('Trial duration in msec: ');
end

if (~isfinite(duration))
    error('duration must be a number');
end

SAMPLERATE = 32000; % in Hz
recSize = (SAMPLERATE * (duration / 1000) + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
if (fid == -1) error('could not open file for reading'); end
headerSize = SkipHeader(fid);

status = fseek(fid, 0, 'eof');
fileSize = ftell(fid);

nrecs = (fileSize - headerSize) / recSize;

fclose(fid);
