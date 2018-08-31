function [avg] = AverageWaveforms(clusterpath)

% Plots mean waveform of spikes that had been sorted into a .cluster file.
% Also shows +/- 1 SD. Note that SE is usually very tiny for large spike
% files.
%
% INPUT
% clusterpath: filepath of .cluster file
%      (the corresponding .tt file, which contains the actual waveforms,
%       is assumed to be in same folder)
%
% Randy Bruno, February 2011

if nargin==0
    [filename pathname OK] = uigetfile('*.cluster?', 'Select cluster file');
    if (~OK) return; end
    clusterpath = [pathname, filename];
    increment = 1;
end

RECSIZE = (1 * 4) + (32 * 4 * 2); % 4-byte timestamp + 32-sample waveform for each of 4 channels and with 2-bytes per sample

% read cluster file
clust = ReadCluster(clusterpath);
clust = RemoveNullSpikes(clust);

% determine spike IDs corresponding to .tt file record numbers
spikeIDs = clust(1:increment:end, 1);
tstamp = clust(1:increment:end, 4);
nSpikes = nrows(spikeIDs);

% open .tt file and skip header
ttpath = [clusterpath(1:(end-8)) 'tt'];
fid = fopen(ttpath, 'r', 'b'); % open as 'big-endian'
headerSize = SkipHeader(fid);

waveforms = nans(nSpikes, 32);
for i = 1:nSpikes
    % go to start of corresponding record
    offset = headerSize + spikeIDs(i) * RECSIZE;
    err = fseek(fid, offset, 'bof');
    if (err)
        disp(['headerSize = ' num2str(headerSize) ...
            '\nspikeID = ' num2str(spikeIDs(i))]);
        error('could not seek to start of record');
    end
    
    % read timestamp
    timestamp = fread(fid, 1, 'ulong') / 10;
    if isempty(timestamp)
        disp(['headerSize = ' num2str(headerSize) ...
            '\nspikeID = ' num2str(spikesIDs(i))]);
        error('could not read stimcode');
    end
    if timestamp ~= tstamp(i)
        disp(['.cluster file timestamp = ' num2str(tstamp(i))]);
        disp(['.tt file timestamp = ' num2str(timestamp)]);
        error('timestamp in .cluster and .tt files do not match');
    end
    
    % read interleaved 4-channel waveform
    waveform = fread(fid, 128, 'int16');
    if isempty(waveform)
        disp(['headerSize = ' num2str(headerSize) ...
            '\nspikeID = ' num2str(spikeIDs(i))]);
        error('could not read waveform');
    end
    waveform = downsample(waveform, 4); % discard other 3 channels
    
    waveforms(i+1, :) = waveform;
end
fclose(fid);

avg = nanmean(waveforms);
sd = nanstd(waveforms);
% se = sd / sqrt(nSpikes);
plot(1:32, avg);
hold on;
line(1:32, avg-sd, 'Color', [.8 .8 .8]);
line(1:32, avg+sd, 'Color', [.8 .8 .8]);


