function [n, x, spontaneous, ON] = PSTH(cluster, winstart, winend, stimcode, Plots, binmax, binwidth)
% PSTH Peri-stimulus time histogram.
% PSTH(CLUSTER) plots a PSTH for the spike data contained in cluster.
% Randy Bruno, April 2003

% spontaneous is in Hz
% ON is in spikes/stim.

if nargin == 0
    [filename pathname OK] = uigetfile('*.*', 'Select .cluster file to analyze');
    if (~OK) return; end
    filepath = [pathname, filename];
    cluster = ReadCluster(filepath);
end 

% must get ntrials before removing null spikes!
ntrials = length(unique(cluster(:,2)));
cluster = RemoveNullSpikes(cluster);
timestamp = cluster(:,4);

if nargin < 3
    winstart = 1;
    winend = 500;
end

if nargin < 6 | isempty(binmax)
    binmax = ceil(max(timestamp)/100)*100;
end

if nargin < 7
    answers = inputdlg({'Window Start (msec)', 'Window End (msec)', 'Binwidth (msec)', 'Binmax (msec)'}, 'Parameters for analysis', 1, {num2str(winstart), num2str(winend), '1', num2str(binmax)});
    winstart = str2num(answers{1});
    winend = str2num(answers{2});
    binwidth = str2num(answers{3});
    binmax = str2num(answers{4});
end

if nargin < 4 | isempty(stimcode)
    stimuli = unique(cluster(:,3));
    if length(stimuli) == 1
        stimcode = stimuli;
    else
        stimcode = [];
    end
end

if (nargin < 5)
    Plots = true;
end

x = linspace(0, binmax, binmax/binwidth + 1);
x = x';

if (isempty(timestamp))
    n = zeros(binmax/binwidth + 1, 1);
else
    n = histc(timestamp, x);
end
n = n / ntrials;

spontaneous = 10 * sum(n(x>=1 & x<101));
ON = sum(n(x>=winstart & x<winend));

if (Plots)
    plot(x, n);
    box off;
    xlabel('msec');
    ylabel('spikes / stimulus / bin');

    switch nargin
        case 1
            title(['spontaneous = ', num2str(spontaneous, 3), ' Hz']);
        otherwise
            if (isempty(stimcode))
                titl = [];
            else
                titl = ['stimulus: ', num2str(stimcode) '; '];
                if stimcode <= -21 & stimcode >= -28
                    titl = ['angle: ' num2str(StimCodeToDegrees(stimcode)) '; ' titl];
                end
            end
            title([titl 'spontaneous = ', num2str(spontaneous, 3), ' Hz; ON = ', num2str(ON, 3), ' spikes/stim; # spikes = ', num2str(length(timestamp))]);
            hold on;
            %area('v6', [winstart winstart winend winend], [0 max(n) max(n) 0], 'FaceColor', 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.1);
            line([winstart winstart], [0 max(n)], 'Color', 'g');
            line([winend winend], [0 max(n)], 'Color', 'r');
            hold off;
    end
    if (~isempty(timestamp) & max(n) > 0)
        %axis([1 max(x) 0 max(n(2:end))]);
        axis([0 max(x) 0 max(n)]);
    end
end

if ncols(n) > nrows(n)
    n = n';
end

if ncols(x) > nrows(x)
    x = x';
end
