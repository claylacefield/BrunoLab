function OverlaySpikes(clusterpath, increment)

% Plots overlaid spikes, which had been sorted into a .cluster file
%
% INPUT
% clusterpath: filepath of .cluster file
%      (the corresponding .tt file, which contains the actual waveforms,
%       is assumed to be in same folder)
% increment: value specifying n-th waveform to display (e.g., 1 = all, 2 =
%       every second spike, so on)
%
% Randy Bruno, February 2011

if nargin==0
    [filename pathname OK] = uigetfile('*.cluster?', 'Select cluster file');
    if (~OK) return; end
    clusterpath = [pathname, filename];
    increment = 10;
end

RECSIZE = (1 * 4) + (32 * 4 * 2); % 4-byte timestamp + 32-sample waveform for each of 4 channels and with 2-bytes per sample

% read cluster file
clust = ReadCluster(clusterpath);
clust = RemoveNullSpikes(clust);

% determine spike IDs corresponding to .tt file record numbers
spikeIDs = clust(1:increment:end, 1);
tstamp = clust(1:increment:end, 4);

% open .tt file and skip header
ttpath = [clusterpath(1:(end-8)) 'tt'];
fid = fopen(ttpath, 'r', 'b'); % open as 'big-endian'
headerSize = SkipHeader(fid);

% go to end of file to get file size, and calc nSpikes in file
fseek(fid, 0, 'eof');
nSpikes = (ftell(fid) - headerSize) / RECSIZE;

for i = spikeIDs'
    % go to start of corresponding record
    offset = headerSize + i * RECSIZE;
    err = fseek(fid, offset, 'bof');
    if (err)
        disp(['headerSize = ' num2str(headerSize) ...
            '\nspikeID = ' num2str(i)]);
        error('could not seek to start of record');
    end
    
    % read timestamp
    timestamp = fread(fid, 1, 'ulong') / 10;
    if isempty(timestamp)
        disp(['headerSize = ' num2str(headerSize) ...
            '\nspikeID = ' num2str(i)]);
        error('could not read stimcode');
    end
    if timestamp ~= tstamp(spikeIDs==i)
        disp(['.cluster file timestamp = ' num2str(timestamp)]);
        disp(['.tt file timestamp = ' num2str(tstamp(spikesIDs==i))]);
        error('timestamp in .cluster and .tt files do not match');
    end
    
    % read interleaved 4-channel waveform
    waveform = fread(fid, 128, 'int16');
    if isempty(waveform)
        disp(['headerSize = ' num2str(headerSize) ...
            '\nspikeID = ' num2str(i)]);
        error('could not read waveform');
    end
    
    waveform = downsample(waveform, 4); % discard other 3 channels
    plot(1:32, waveform);
    hold on;
end

fclose(fid);
