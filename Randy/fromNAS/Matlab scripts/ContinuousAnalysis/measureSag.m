function [sag] = measureSag(filepath, duration, stimOnset, ssstart, ssend, recordlist)

% MEASURESAG(FILEPATH, DURATION, STIMONSET, SSSTART, SSEND)
% Measure input resistance and tau of a patched cell in response to
% hyperpolarizing pulses.
%
% Assumes data is collected with ntrode.vi
%
% INPUTS
% filepath: string specifying the path of the file to measure
% duration: duration of records in msecs
% stimOnset: time of pulse onset in msecs
% ssstart: start of window for measuring steady state
% ssend: end of window for measuring steady state
%
% OUTPUTS
% sag: expressed as difference of peak and steady state as a function of
%
% Randy Bruno, October 2010 (adapted from measureRi.m)

if (nargin < 1)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 5)
    answers = inputdlg({'Duration (ms)', 'Pulse Onset (ms)', 'Steady state start (ms)', 'Steady state end (ms)', 'Records to process'}, ...
        'Parameters for measuring Ri', 1, {'800', '100', '499', '599', ''});
    duration = str2num(answers{1});
    stimOnset = str2num(answers{2});
    ssstart = str2num(answers{3});
    ssend = str2num(answers{4});
    recordlist = str2num(answers{5});
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);

if nargin < 6 & length(recordlist) == 0
    nrecs = GetNumberOfRecords(filepath, duration);
    recordlist = 1:nrecs;
end

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

average = zeros(nScans, 1);
laststim = NaN;
x = linspace(0, duration, nScans);

i = 0;
for trial = recordlist
    [stimcode, data] = GetRecord(fid, headerSize, duration, trial-1);
    i = i + 1;
    average = MemorylessAverage(average, data, i);
end
average = average * SCALINGFACTOR;
fclose(fid);

plot(x, average);
xlabel('msec');
ylabel('mV');

Vbaseline = mean(average(x < stimOnset));
line([min(x) max(x)], [Vbaseline Vbaseline], 'LineStyle', '--', 'Color', 'r');
Vsteadystate = mean(average(x > ssstart & x < ssend));
line([min(x) max(x)], [Vsteadystate Vsteadystate], 'LineStyle', '--', 'Color', 'r');

Vpeak = min(average(x > stimOnset & x < stimOnset+100));
sag = 100 * (Vsteadystate - Vpeak) / (Vbaseline - Vpeak);

title(sprintf([strrep(filepath, '\', '\\') ...
        '\nstimcode = ' num2str(stimcode) ...
        ', reps = ' num2str(i) ...
        ', sag = ' num2str(sag) '%']));
    
