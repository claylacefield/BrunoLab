function [timestamp, trial, stimcode, waveform] = GetOneSpike(fid)
% GETONESPIKE Read a single spike record from a .dat file generated by ntrode.vi
% GETONESPIKE(FID), where FID is file identified,
% returns an array containing one spike record's data.

timestamp = fread(fid, 1, 'uint') * 0.3125;
trial = fread(fid, 1, 'int');
stimcode = fread(fid, 1, 'float32');
waveform = fread(fid, 32, 'float32');