function AnalyzeRiByState(filepath, duration)

if (nargin < 2)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];

    answers = inputdlg({'Duration (ms)'}, ...
        'Parameters for measuring Ri', 1, {'500'});
    duration = str2num(answers{1});
end

states = ClassifyUpDownStates(filepath, duration, 1, 100, 400, 500);

% make record lists for each category of state
nrecs = GetNumberOfRecords(filepath, duration);
recordlist = 1:nrecs;
UPlist = recordlist(states == 1);
DOWNlist = recordlist(states == -1);
amblist = recordlist(states == 0);

figure;
[Rup, tau] = measureRi(filepath, duration, 100, 150, 199, UPlist);
set(gcf, 'Name', 'UP state');

figure;
[Rdown, tau] = measureRi(filepath, duration, 100, 150, 199, DOWNlist);
set(gcf, 'Name', 'DOWN state');

figure;
[Ramb, tau] = measureRi(filepath, duration, 100, 150, 199, amblist);
set(gcf, 'Name', 'ambiguous state');
