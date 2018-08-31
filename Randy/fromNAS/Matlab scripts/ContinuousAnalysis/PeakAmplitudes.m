function [peak, TimePeakToBaseline] = PeakAmplitudes(average, x, stimuli, stimOnset, winstart, winend)

% Randy Bruno, September 2010
% This function is designed to be a subroutine of PlotLFPbyStim or
% any other script that needs to automate the measurement of peak
% amplitudes.

nStim = length(stimuli);
peak = zeros(nStim, 1);
TimePeakToBaseline = zeros(nStim, 1);
for i = 1:nStim
    baseline = median(average(x < stimOnset, i));
    y = max(average(x >= winstart & x <= winend, i));
    peak(i) = y-baseline;
    
    peaktime = find(average(:,i)==y);
    peaktime = peaktime(1);
    returntime = find(average(:,i) <= baseline);
    returntime = returntime(returntime > peaktime);
    if ~isempty(returntime)
        returntime = returntime(1);
        peaktime = x(peaktime);
        returntime = x(returntime);
        TimePeakToBaseline(i) = returntime - peaktime;
    else
        TimePeakToBaseline(i) = NaN;
    end
end
