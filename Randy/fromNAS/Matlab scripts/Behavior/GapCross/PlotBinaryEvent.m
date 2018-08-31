function [x, y] = PlotBinaryEvent(timestamps, events, code, plotoffset)

% plot a binary behavioral variable when ON/OFF times have been recorded
% (e.g., beam break). Limits this to events containing code. For example,
% if there exists events "BM1_ON", "BM1_OFF", "BM2_ON", etc. and code is
% "BM1", function finds BM1_ON and BM1_OFF events and plots their times.
%
% timestamps: times of events to search
% events: event information
% code: string to search within events
% plotoffset: if plotting multiple events on the same graph, keep
% incrementing this by 1 for subsequent calls. Need to execute "hold on"
% before the second call to PlotBinaryEvent to prevent overwriting.
%
% Randy & Claire, November 2013

if nargin < 3
    error('requires at least 3 arguments');
end
if nargin < 4
    plotoffset = 0;
end

COLOR = 'krgbymc';

% get timestamps of events containing code
selected = timestamps(~cellfun(@isempty, strfind(events, code)));

nevents = length(selected);
x = repeach(selected, 2);
y = repmat([0 1 1 0]' + plotoffset*2, nevents/2, 1);
plot(x, y, COLOR(plotoffset+1));
xlabel('seconds');