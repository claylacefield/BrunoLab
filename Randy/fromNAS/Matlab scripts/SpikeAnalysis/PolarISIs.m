function [meanisi, stimuli] = PolarISIs(cluster, winstart, winend, nreps, Plots)

% POLARISIS(CLUSTER, WINSTART, WINEND, NREPS) creates a polar plot of
% ISIs collected during deflections of a whisker in various directions.
% CLUSTER is the ordinary spike data table.
% WINSTART and WINEND are the start and end of the response window in msecs.
% NREPS is the number of repetitions per angle.
% Randy Bruno, April 2004

switch nargin
    case 0
        [filename pathname OK] = uigetfile('*.cluster?', 'Select cluster file');
        if (~OK) return; end
        filepath = [pathname, filename];
        cluster = ReadCluster(filepath);  
        winstart = 150;
        winend = 350;
    case 1
        winstart = 150;
        winend = 350;
    case 2
        error('PolarPlot: winend must be specified if winstart is given')
end

% convert stimulus codes to degrees
stimulus = StimCodeToDegrees(cluster(:,3));
stimuli = unique(stimulus);
nStim = length(stimuli);

if nargin < 4 | isempty(nreps)
    nreps = (max(cluster(:,2)) + 1) / nStim;
end

if nargin < 5
    Plots = true;
end

timestamp = cluster(:,4);

% convert degrees to radians
x = stimuli * pi / 180;

% generate ISI distributions by direction
minisi = Inf;
maxisi = -Inf;
medianisi = zeros(nStim, 1);
meanisi = zeros(nStim, 1);
for i = 1:nStim
    if Plots
        subplot(nStim, 2, 2*i-1);
    end
    clust = cluster(stimulus == stimuli(i) & timestamp >= winstart & timestamp < winend, :);
    isis = ISIhist(clust);
    box off;
    if length(excise(isis)) > 0
        medianisi(i) = median(excise(isis));
        meanisi(i) = signif(mean(excise(isis)), 1);
    else
        medianisi(i) = NaN;
        meanisi(i) = NaN;
    end
    minisi = min(minisi, min(isis));
    maxisi = max(maxisi, max(isis));
    title(['mean = ' num2str(meanisi(i)) ', median = ' num2str(medianisi(i)) ', min = ' num2str(min(isis)) ', max = ' num2str(max(isis))]);
    if i < nStim
        set(gca, 'XTickLabel', ' ');
    end
end

if (Plots)
    % put all distributions on same x-scale
    for i = 1:nStim
        subplot(nStim, 2, 2*i-1);
        xlim([minisi, maxisi]);
    end 
    
    subplot(nStim, 2, 2:2:nStim);
    if nStim > 1
        % polar plot of mean ISIs
        polar([x; x(1)], [meanisi; meanisi(1)]); %extra point is needed to prevent break in polar plot
        set(findobj('Type','line'),'LineWidth',2);
        title('mean ISI');
    end
    
    subplot(nStim, 2, (nStim+2):2:(nStim*2));
    if nStim > 1
        % polar plot of median ISIs
        polar([x; x(1)], [medianisi; medianisi(1)]); %extra point is needed to prevent break in polar plot
        set(findobj('Type','line'),'LineWidth',2);
        title('median ISI');
    end
    
    plotedit('ON');
end
