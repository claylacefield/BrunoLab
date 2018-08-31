function [n, stimuli, spon] = PolarSpikes(clust, winstart, winend, nreps, Plots)

% POLARSPIKES(CLUST, WINSTART, WINEND, NREPS) creates a polar plot of
% spikes collected during deflections of a whisker in various directions.
% CLUST is the ordinary spike data table.
% WINSTART and WINEND are the start and end of the response window in msecs.
% NREPS is the number of repetitions per angle.
% Randy Bruno, April 2003

switch nargin
    case 0
        clust = ReadCluster;
        winstart = 0;
        winend = 500;
    case 1
        winstart = 0;
        winend = 500;
    case 2
        error('PolarPlot: winend must be specified if winstart is given')
end

% convert stimulus codes to degrees
stimulus = StimCodeToDegrees(clust(:,3));
stimuli = unique(stimulus);
nStim = length(stimuli);
if nStim ~= 8
    message = ['# of stimuli types: ' num2str(nStim) '. Check if this is really a polar data file or not. '];
    h = warndlg(message);
%     uiwait(h);
end

if nargin < 4 | isempty(nreps)
    nreps = (max(clust(:,2)) + 1) / nStim;
end

if nargin < 5
    Plots = true;
end

timestamp = clust(:,4);

%calculate overall spontaneous activity
spikes = stimulus(timestamp >= 1 & timestamp < 101);
spon = signif(10 * length(spikes) / nreps / nStim, 3);

%calculate responses for each stimulus type
spikes = stimulus(timestamp >= winstart & timestamp < winend);
if (isempty(spikes))
    n = zeros(nStim, 1);
else
    n = histc(spikes, stimuli);
end
n = n / nreps;
% convert degrees to radians
x = stimuli * pi / 180;

% generate PSTHs
maximum = 0;
for i = 1:nStim
    if Plots
        subplot(nStim, 2, 2*i-1);
    end
    angle = stimuli(i);
    code = -(angle/45 + 21);
    subset = clust(clust(:,3)==code,:);
    [PSTHn, bins] = PSTH(subset, winstart, winend, [], Plots, 500, 1);
    if (Plots)
        box off;
        if (~isempty(subset))
            maximum = max(maximum, max(PSTHn));
        end
        xlim([2 500]);
        if (i < nStim)
            set(gca, 'XTickLabel', '');
            xlabel('');
        end
        if (i ~= round(nStim / 2))
            ylabel('');
        end
    end
end

if (Plots)
    % put all PSTHs on same scale and indicate response window
    for i = 1:nStim
        subplot(nStim, 2, 2*i-1);
        ylim([0 maximum]);
        %hold on;
        %area('v6', [winstart winstart winend winend], [0 maximum maximum 0], 'FaceColor', 'yellow', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
        %hold off;
    end

    subplot(nStim, 2, linspace(2,nStim*2,nStim));
    if nStim > 1
        % polar plot of responses
        polar([x; x(1)], [n; n(1)]); %extra point is needed to prevent break in polar plot
        set(findobj('Type','line'),'LineWidth',2);
        title(['spon = ', num2str(spon), ...
           ' Hz, mean = ', num2str(mean(n)), ...
           ' sp/st, max = ', num2str(max(n)), ...
           ' sp/st, nreps/stim = ' num2str(nreps)]);
       [angle, magnitude, sumx, sumy] = meanVector(n, stimuli);
       line([0 sumx], [0 sumy]); 
    end
    plotedit('ON');
end

n = reshape(n, length(n), 1);
