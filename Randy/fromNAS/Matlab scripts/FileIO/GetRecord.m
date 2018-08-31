function [stimcode, data] = GetRecord(fid, headerSize, duration, trial)

% Read a record from a continuous (e.g., whole cell, LFP, etc.) .dat file.
% fid: file ID (i.e., from fopen)
% nScansPerRec: number of scans per record
% trial: number of trial to be read (zero-indexed)
%
% Randy Bruno, October 2003

SAMPLERATE = 32000;

nScansRecord =  duration * SAMPLERATE / 1000;
recSize = (nScansRecord + 1) * 4;
offset = headerSize + trial * recSize;

err = fseek(fid, offset, 'bof');
if (err) error('could not seek to start of record'); end

stimcode = fread(fid, 1, 'float32');
data = fread(fid, nScansRecord, 'float32');
