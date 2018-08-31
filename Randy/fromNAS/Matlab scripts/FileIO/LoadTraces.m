function [traces, time, stimcodes, filepath] = loadTraces(filepath, duration)
 
% LOADTRACES(FILEPATH) Returns an array of raw intracellular traces and a
% time vector.
 
if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 2)
    duration = input('Trial duration in msec: ');
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
nrecs = floor(GetNumberOfRecords(filepath, duration));

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

traces = nans(nrecs, nScans);
stimcodes = nans(nrecs, 1);
for i = 1:nrecs
    stimcodes(i) = fread(fid, 1, 'float32');
    if (feof(fid)) break; end
    traces(i, :) = fread(fid, nScans, 'float32') * SCALINGFACTOR;
    if (feof(fid)) break; end
end

time = linspace(0, duration, nScans);
 
fclose(fid);


 

