function [new, spikeindex] = RemoveSpike2(old, msPrePeak, msPostPeak, thresh)

% NEW = REMOVESPIKE(OLD) Removes spikes from whole-cell recording.
% Finds peaks of spikes in OLD, deletes a few msecs before and after, fills
% in the empty space by linear interpolation.
%
% Randy Bruno, October 2003
% Revised RemoveSpike in February 2006 to use a simple (faster) thresholding detector rather
% than a detector based on median filtering.

if nargin < 2
    msPrePeak = 0.8;
    msPostPeak = 3.0;
end

SAMPLERATE = 32000;
SAMPLESPERMS = SAMPLERATE / 1000;

spikeindex = threshold(old, thresh, SAMPLESPERMS * 2); % threshold the spikes to find indexes

% find indices of absolute peaks of spikes
n = length(spikeindex);
peaks = zeros(n, 1);
for i = 1:n
    exEnd = spikeindex(i) + 2 * SAMPLESPERMS; % necessary for spikes occurring close to record boundary
    if exEnd > length(old)
        exEnd = length(old);
    end
    excerpt = old(spikeindex(i):exEnd); %assume peak is reached within 2 ms of trigger point
    peakindex = find(excerpt == max(excerpt));
    peakindex = peakindex(1);
    peaks(i) = peakindex + spikeindex(i) - 1;
end

% replace spikes with linear interpolation
new = old;
for i = 1:n
    % find Vm at designated points before and after peak of spike
    spikestart = peaks(i) - round(msPrePeak * SAMPLESPERMS);
    spikeend = peaks(i) + round(msPostPeak * SAMPLESPERMS);
    if spikeend > length(old)
        spikeend = length(old) - 1;
    elseif spikestart < 2
        spikestart = 2;
    end
    Vpre = old(spikestart - 1);
    Vpost = old(spikeend + 1);
    m = (Vpost - Vpre) / ((spikeend + 1) - (spikestart - 1));
    for j = spikestart:spikeend
        new(j) = Vpre + m*(j-spikestart+1);
    end
    old = new;
end
