function [slope, ltime, utime, lbound, ubound] = SlopeOfPSP(signal, baseline, peak)

% SLOPEOFPSP(SIGNAL) Calculate a slope parameter for rising phase of PSP.
% Adapted from Feldmeyer et al 1999.
% General algorithm: 1) excerpt the
% 20%-80% region of the rising phase, 3) fit a function
%
% Randy Bruno, October 2003

SAMPLERATE = 32000;
SAMPLESPERMS = SAMPLERATE / 1000;

lbound = (peak-baseline) * 0.3 + baseline;
ubound = (peak-baseline) * 0.7 + baseline;

% find the time of the given peak value
peaktime = find(signal==peak);
peaktime = peaktime(1);

% work backwards from the peak to find the time of the 80% value
sig = -ReverseArray(signal(1:peaktime));
utime = threshold(sig, -ubound, length(sig));
utime = (peaktime - utime) / SAMPLESPERMS;


% continue working backwards from the peak to find the time of the 20% value
ltime = threshold(sig, -lbound, length(sig));
ltime = (peaktime - ltime) / SAMPLESPERMS;

if (isempty(ltime) | isempty(utime))
    risetime = NaN;
    slope = NaN;
else
    ltime = ltime(1);
    utime = utime(1);  
    slope = (ubound - lbound) / (utime - ltime);
end
