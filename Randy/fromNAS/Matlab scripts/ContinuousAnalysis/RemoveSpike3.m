function [new, spikeindex, PostPeaks] = RemoveSpike3(old, msPrePeak, thresh)

% NEW = REMOVESPIKE3(OLD) Removes spikes from whole-cell recording.
% Finds peaks of spikes in OLD, deletes a few msecs before and after, fills
% in the empty space by linear interpolation.
%
% Randy Bruno, October 2003
% Revised RemoveSpike in February 2006 to use a simple (faster) thresholding detector rather
% than a detector based on median filtering.
% Revised May 2011 to find spike duration using derivative of signal.

if nargin < 2
    msPrePeak = 0.8;
    msPostPeak = 3.0;
end

SAMPLERATE = 32000;
SAMPLESPERMS = SAMPLERATE / 1000;

deriv = diff(old);

spikeindex = threshold(deriv, thresh, SAMPLESPERMS * 2); % threshold the spikes to find indexes
spikeindex = spikeindex + 1; % correct for offset caused by diff function

% find indices of absolute peaks of spikes and derivatives
n = length(spikeindex);
peaks = zeros(n, 1);
dpeaks = zeros(n, 1);
PostPeaks = zeros(n, 1);
for i = 1:n
    exEnd = spikeindex(i) + 2 * SAMPLESPERMS; % necessary for spikes occurring close to record boundary
    if exEnd > length(old)
        exEnd = length(old);
    end
    excerpt = old(spikeindex(i):exEnd); %assume peak is reached within 2 ms of trigger point
    peakindex = find(excerpt == max(excerpt));
    peakindex = peakindex(1);
    peaks(i) = peakindex + spikeindex(i) - 1;
    
    excerpt = deriv(spikeindex(i)-1:(exEnd-1)); %assume peak is reached within 2 ms of trigger point
    peakindex = find(excerpt == max(excerpt));
    peakindex = peakindex(1);
    dpeaks(i) = peakindex + spikeindex(i) - 1;
end

% replace spikes with linear interpolation
new = old;
for i = 1:n
    % Tried the following but did not like the results.
    % find Vm just before start of spike by excerpting the derivative just before the
    % peak, reversing the array, and looking for the first zero crossing
%     excerpt = deriv((dpeaks(i) - 1 - SAMPLESPERMS):(dpeaks(i)-1));
%     excerpt = -ReverseArray(excerpt);
%     spikestart = threshold(excerpt, 0.3, 2);
%     if isempty(spikestart)
%         spikestart = length(excerpt);
%     end
%     spikestart = dpeaks(i) - 1 - spikestart(1);
%     disp(spikestart);

    spikestart = peaks(i) - round(msPrePeak * SAMPLESPERMS);
    Vpre = old(spikestart - 1);
    
    % find Vm just after end of spike, where end of spike is defined by the
    % distance from the derivative peak to the derivative's return to 0
    %
    % Step 1. Find mininimum after peak (bottom of AHP)
    exEnd = min(length(deriv), dpeaks(i) + 2 * SAMPLESPERMS - 1);
    excerpt = deriv((dpeaks(i)-1):exEnd);
    minindex = find(excerpt == min(excerpt));
    minindex = minindex(1);
    %
    % Step 2. Find the first 0 crossing after the minimum  
    exEnd = min(length(deriv), dpeaks(i)+ minindex + 10 * SAMPLESPERMS);
    excerpt = deriv((dpeaks(i) + minindex):exEnd);
    zeroindex = threshold(excerpt, 0, 2);
    if isempty(zeroindex)
        zeroindex = length(deriv);
    end
    zeroindex = zeroindex(1);
    %
    % Step 3. calculate DOUBLE THE time from peak to 0 zero crossing
    msPostPeak = 2 * (minindex + zeroindex) / SAMPLESPERMS;
	PostPeaks(i) = msPostPeak;
    
    spikeend = peaks(i) + round(msPostPeak * SAMPLESPERMS);
    if spikeend > length(old)
        spikeend = length(old) - 1;
    elseif spikestart < 2
        spikestart = 2;
    end
    
    Vpost = old(spikeend + 1);
    m = (Vpost - Vpre) / ((spikeend + 1) - (spikestart - 1));
    for j = spikestart:spikeend
        new(j) = Vpre + m*(j-spikestart+1);
    end
    old = new;
end
