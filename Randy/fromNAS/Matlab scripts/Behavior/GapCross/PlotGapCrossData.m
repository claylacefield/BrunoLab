function [timestamps, events] = PlotGapCrossData

% Plot gap cross data (no real processing)
%
% Claire & Randy, November 2013

[filename, pathname] = uigetfile('*.txt', 'Select a text file of behavior to read');
filepath = [pathname filename];

% read in text file
fid = fopen(filepath);
hs = SkipHeader(fid, 'BEGIN DATA');
C = textscan(fid, '%d %q', 'Delimiter', '\t');
fclose(fid);
timestamps = double(C{1}) / 1000; % express time in units of seconds
events = C{2};

% plot the beam breaks
PlotBinaryEvent(timestamps, events, 'BM1'); hold on;
PlotBinaryEvent(timestamps, events, 'BM2', 1);
PlotBinaryEvent(timestamps, events, 'BM3', 2);
PlotBinaryEvent(timestamps, events, 'BM4', 3);

% add gap changes to plot
subset = ~cellfun(@isempty, strfind(events, 'Gap'));
stime = timestamps(subset);
sgap = cellfun(@(x)x(end-1:end), events(subset), 'UniformOutput', false);
for i = 1:length(stime)
    text(double(stime(i)), 3.25, sgap{i});
end

% add rewards to plot
stime = timestamps(~cellfun(@isempty, strfind(events, 'rewarded')));
for i = 1:length(stime)
    text(stime(i), 3.75, '*');
end
