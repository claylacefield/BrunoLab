function states = ClassifyUpDownStates(filepath, duration, winstart1, winend1, winstart2, winend2)

% [STATES] = CLASSIFYUPDOWNSTATES(FILEPATH, DURATION, WINSTART1, WINEND1,
% WINSTART2, WINEND2)
%
% Classifies trials as being in an UP, DOWN or ambigous state according to
% the average Vm in two different time windows.
%
% FILEPATH: path to whole-cell .dat file to analyze
% DURATION: trial duration in msec
% WINSTART1: start of window 1 in msec
% WINEND1: end of window 1 in msec
% WINSTART2/WINEND2: analogous
%
% STATES: an array having as many elements as the file had trials, where
% STATES(i) indicates the state of trial i. 1=UP, -1=DOWN, 0=ambiguous
%
% Randy Bruno, February 2004

if nargin == 0
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if nargin < 2
    answers = inputdlg({'Trial duration (ms)', 'Window1 Start (ms)', 'Window1 End (ms)', 'Window2 Start (ms)', 'Window2 End (ms)'}, ...
        'Parameters for classifying UP/DOWN states', 1, {'500', '1', '100', '400', '500'});
    duration = str2num(answers{1});
    winstart1 = str2num(answers{2});
    winend1 = str2num(answers{3});
    winstart2 = str2num(answers{4});
    winend2 = str2num(answers{5});
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
x = linspace(0, duration, nScans);

nrecs = GetNumberOfRecords(filepath, duration);

% compute Vm distribution, find 30- and 70-th percentiles
[prc1, prc2, f, xi] = VmDistribution(filepath, duration, winstart1, winend1, 40, 60, false, true);
prc1 = prc1 / SCALINGFACTOR
prc2 = prc2 / SCALINGFACTOR

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);
states = zeros(nrecs, 1);
for i = 1:nrecs
    [stimcode, data] = GetRecord(fid, headerSize, duration, i-1);
    excerpt1 = data(x >= winstart1 & x <= winend1);
    excerpt2 = data(x >= winstart2 & x <= winend2);
 
    if (mean(excerpt1) > prc2 & mean(excerpt2) > prc2)
        states(i) = 1; % UP state
    else
        if (mean(excerpt1) < prc1 & mean(excerpt2) < prc1)
            states(i) = -1; % DOWN state
        else
            states(i) = 0; % ambiguous
        end
    end
    %figure;
    %plot(data);
    %title(num2str(states(i)));
    %ans = inputdlg(' ');
    %close;
end
