function [amp, nshift] = STAanalysis(duration, cluster, averagingpath, limit, Vstart, Vend, GreaterThan, memoryless, winstart, winend, trialStart, trialEnd, TClockout, ShiftCorrect)

% This is intended to be the core of the STA analysis that is called by the
% STA GUI and any batch processing programs.


% excerpt specified time window
cluster = cluster(cluster(:,4) >= winstart & cluster(:,4) <= winend, :);
% excerpt specified trials
cluster = cluster(cluster(:,2) >= trialStart & cluster(:,2) <= trialEnd, :);

% apply thalamic ISI lockout, if any
if (TClockout)
    ISI = ISIof(cluster);
    %ISIx = [ISI(2:end); NaN];
    cluster = cluster(ISI > TClockout, :);
end

% If shift correcting, remove the last trial's spikes.
% This is necessary because the Shift Corrector will not use the last
% trial's spikes, and we want both the raw and corrector to be based off
% the same set of spikes.
if (ShiftCorrect)
    maxTrial = max(cluster(:,2));
    cluster = cluster(cluster(:,2) ~= maxTrial, :); % +1 shift corrector
    %cluster = cluster(cluster(:,2) ~= 0, :); % -1 shift corrector
end

% compute/plot the raw STA
[x, raw, nraw] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, Vstart, Vend, GreaterThan, memoryless);

if nraw < 10
    amp = NaN;
    nshift = NaN;
    return;
end

raw = raw - 7; % correct for jxn potential
h = figure;
whitebg('w');
if (ShiftCorrect) subplot(4,1,1); end
figure(h);
plot(x, raw);
line([0 0], ylim, 'Color', 'black');
box off;
ylabel('Vm');

% compute/plot a shift corrector and a subtraction
if (ShiftCorrect)
    cluster(:,2) = cluster(:,2) + 1;

    [x, shift, nshift] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, Vstart, Vend, GreaterThan, memoryless);
    shift = shift - 7; % correct for jnxn potential
    mi = min([raw shift]);
    mx = max([raw shift]);
    ylim([mi mx]);
    figure(h);
    subplot(4,1,2);
    plot(x, shift);
    box off;
    ylim([mi mx]);
    line([0 0], ylim, 'Color', 'black'); 
    ylabel('Vm');
    title('shift corrector');
    
    corrected = raw - shift;
    
    subplot(4,1,3);
    plot(x, corrected);
    box off;
    line([0 0], ylim, 'Color', 'black'); 
    ylabel('delta Vm');
    title('corrected sta');
    figure(h);
    subplot(4,1,4);
    subset = x >= -10 & x <= 50;
    plot(x(subset), corrected(subset));
    box off;
    line([0 0], ylim, 'Color', 'black'); 
    xlabel('lag (msec)');
    ylabel('delta Vm');
    amp = max(corrected(x>1 & x<20)) - corrected(x==0.5);
    title(['amplitude = ' num2str(amp)]);
    
    % compute a simple significance test of the post-thalamic Vm change
    spon = corrected(x < -5);
    CI = 2.57 * std(spon) + corrected(x==0); % 99% 2-tailed CI
    subplot(4,1,3);
    line([min(x) max(x)], [CI CI], 'LineStyle', '--');
    subplot(4,1,4);
    line([-10 50], [CI CI], 'LineStyle', '--');
end

if ShiftCorrect
    spikestr = ['raw spikes: ' num2str(nraw) ', corrector spikes: ' num2str(nshift)];
    subplot(4,1,1);
else
    spikestr = ['raw spikes: ' num2str(nraw)];
end
title(sprintf([strrep(averagingpath, '\', '\\') ...
    ', trials: ' num2str(trialStart) '-' num2str(max(cluster(:,2))) ...
    ', TC lockout: ' num2str(TClockout) ...
    ', ' spikestr ...
    '\nraw sta']));

orient landscape;
set(gcf, 'Name', averagingpath);
