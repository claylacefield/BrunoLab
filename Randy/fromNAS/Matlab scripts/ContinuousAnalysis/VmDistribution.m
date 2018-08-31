function [prc1, prc2, f, xi, xbar] = VmDistribution(filepath, duration, winstart, winend, trialStart, trialEnd, p1, p2, density, PLOT, dsample, method)
% VMDISTRIBUTION
%
% Randy Bruno, April 2005

if nargin == 0
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if nargin < 12
    answers = inputdlg({'Duration (ms)', 'Window Start (ms)', 'Window End (ms)', 'Trial Start', 'Trial End', 'Percentile 1 (%)', 'Percentile 2 (%)', 'downsample'}, ...
        'Parameters for calculating Vm distribution', 1, {'3000', '1', '500', '0', '1000', '25', '75', '10'});
    duration = str2num(answers{1});
    winstart = str2num(answers{2});
    winend = str2num(answers{3});
    trialStart = str2num(answers{4});
    trialEnd = str2num(answers{5})
    p1 = str2num(answers{6});
    p2 = str2num(answers{7});
    dsample = str2num(answers{8});
    density = false;
    PLOT = true;
    method = 'all';
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
SCANSPERMS = SAMPLERATE / 1000;
nScans = SAMPLERATE * (duration / 1000);
x = linspace(0, duration, nScans);

nrecs = GetNumberOfRecords(filepath, duration)
if trialEnd >= nrecs
    trialEnd = nrecs-1;
end

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);
excerptsize = (winend - winstart) * SCANSPERMS;
if rem(excerptsize, dsample)
    excerpts = repmat(nan, nrecs, floor(excerptsize/dsample)+1);
else
    excerpts = repmat(nan, nrecs, floor(excerptsize/dsample));
end
for i = (trialStart+1):(trialEnd+1)
    [stimcode, data] = GetRecord(fid, headerSize, duration, i-1);
    excerpt = data(x >= winstart & x <= winend);
    if (max(excerpt - median(excerpt)) <= 0.3)
        excerpt = excerpt(1:dsample:end,:);
        excerpts(i, :) = excerpt';    
    else
        disp(['rejected trial #' num2str(i)]);
        excerpts(i, :) = NaN;
    end
end
if strcmp(method, 'all')
    excerpts = reshape(excerpts, nrows(excerpts)*ncols(excerpts), 1) * SCALINGFACTOR;
end
if strcmp(method, 'mean')
    excerpts = mean(excerpts, 2) * SCALINGFACTOR;
end
if strcmp(method, 'median')
    excerpts = median(excerpts, 2) * SCALINGFACTOR;
end

if density
    [f, xi] = ksdensity(excerpts);
else
    f = NaN;
    xi = NaN;
end

prc1 = prctile(excerpts, p1);
prc2 = prctile(excerpts, p2);
xbar = mean(excerpts);

if PLOT
    [n, xout] = hist(excerpts, 100);
    bar(xout, n);
    if density
        ax1 = gca;
        ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','k','YColor','k');
        hl2 = line(xi, f,'Color','k','Parent',ax2);
    end
    line([prc1 prc1], [0 max(n)]);
    line([prc2 prc2], [0 max(n)]);
    box off;
    plotedit on;
    title([num2str(p1) '% = ' num2str(signif(prc1, 1)) ', ' num2str(p2) '% = ' num2str(signif(prc2, 1)) ', mean = ' num2str(xbar)]);
end


