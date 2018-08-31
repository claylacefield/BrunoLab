function [n, x] = PopPSTH(filepath, column, winstart, winend, Plots)

% Population PSTH
%
% INPUTS
%
% filepath: string specifying a spreadsheet
%
% column: string specifying the name of a column in spreadsheet. This
% column should contain the filepaths to process.
%
% winstart, winend: numerics specifying response windows (for individual
% PSTHs only)
%
% Plots: boolean, set to true if individual PSTHS should be plotted
%
% Randy Bruno, October 2003 - original version
% Randy Bruno, February 2011 - added 'column' feature

%for TC pairs

duration = 3000;
binwidth = 1;
xstart = 1;
xend = 3000;

%for CDK PW stuff
% duration = 500;
% binwidth = 1;
% xstart = 1;
% xend = 500;

if nargin < 1
    [filename pathname OK] = uigetfile('.xls', 'Select spreadsheet containing filepaths');
    if (~OK) return; end
    filepath = [pathname, filename]
end

if nargin < 3
    winstart = 150;
    winend = 350;
end

if nargin < 4
    Plots = false;
end

data = xlsreadastext(filepath); %read data
attach;
nFiles = length(eval(column));

nspikes = zeros(nFiles, duration/binwidth + 1);
nCellsUsed = 0;
for i = 1:nFiles
    filename = eval([column '{i}']);
    filename = [filename(1:2) '\Heidelberg' filename(3:end)];
    disp(['i = ', num2str(i), ': ', filename]);
    % if there is a file listed
    if ~isempty(filename) && ~strcmp(filename, 'NA') && dur(i) == 3000
        %& isfinite(medfilt(i)))
        % and the data was filterable...
        %filename = [filename(1:(length(filename)-4)) '-spikes.cluster1'];
        cluster = ReadCluster(filename, true);
        if ~isnan(cluster)
            %cluster = ExtractCondition(cluster, -25); %EXTRACT JUST BACKWARDS CONDITION FOR CDK
            if Plots
                figure('Name', filename);
            end
            [n, x] = PSTH(cluster, winstart, winend, [], Plots, duration, binwidth);
            n=n';
            nspikes(i, :) = n;
            nCellsUsed = nCellsUsed + 1;
        end
    else
        nspikes(i, :) = NaN;
    end
end
% discard bins outside of specified window
nspikes = nspikes(:, x >= xstart & x <= xend);
x = x(x >= xstart & x <= xend);

n = zeros(length(x), 1);
for i = 1:length(x)
    n(i) = nanmean(nspikes(:, i));
end

figure;
bar(x, n);
xlim([xstart xend]);
xlabel('msec');
ylabel('spikes/stimulus/bin/cell');
title(['Population PSTH (' num2str(binwidth) '-ms bins, ' num2str(nCellsUsed) ' cells)']);
box off;
