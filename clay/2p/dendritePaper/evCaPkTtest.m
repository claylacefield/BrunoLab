function [rejNull, pval] = evCaPkTtest(ev1ca, ev2ca)

%% USAGE: [rejNull, pval] = evCaPkTtest(ev1ca, ev2ca);
% script to find peak amplitudes for events in a calcium epoch
% and perform ttest on 2 groups
% NOTE: right now only works with 33frame windows
% EXAMPLE 091518: [rejNull, pval] = evCaPkTtest(itiWhiskBoutCaMouseStruc.itiWhiskBoutCa, rew4b)

% event 1 peaks
for i = 1:size(ev1ca,2)
    pks = findpeaks(ev1ca(10:20,i), 1:11,  'MinPeakDistance', 9); 
    try
        ev1amp(i) = max(pks); 
    catch
        ev1amp(i) = NaN;
    end 
end

% event 2 peaks
for i = 1:size(ev2ca,2)
    pks = findpeaks(ev2ca(10:20,i), 1:11,  'MinPeakDistance', 9); 
    try
        ev2amp(i) = max(pks); 
    catch
        ev2amp(i) = NaN;
    end 
end

[rejNull, pval] = ttest(ev1amp, ev2amp);