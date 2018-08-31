function [connected, psp, nshift, x, corrected, ISIsRaw, meanVmRaw] = STAanalysisWithBootstrap(averagingpath, duration, triggerpath, cluster, winstart, winend, trialStart, trialEnd, ...
    lockout, lockout2, successorLockout, burstSpike, burstCrit, ShiftCorrect, limit, UpDownBorder, GreaterThan, memoryless, measurePSP, Plots, onset, offset)

% This is to serve as the core subroutine for the STA GUI and any STA batch
% processing programs.
%
% Randy Bruno, April 2005

% excerpt specified time window
cluster = cluster(cluster(:,4) >= winstart & cluster(:,4) <= winend, :);
%disp(nrows(cluster));
% excerpt specified trials
cluster = cluster(cluster(:,2) >= trialStart & cluster(:,2) <= trialEnd, :);
%disp(nrows(cluster));

ISI = ISIof(cluster);
ISInext = [ISI(2:end); NaN];
% or excerpt just the n-th spike of high frequency Ca++ bursts
if (burstSpike > 0)
    %[nS, tr] = SpikesPerTrial(cluster, false);
    %nSpikes = zeros(nrows(cluster), 1);
    %for i = 1:nrows(cluster)
    %    nSpikes(i) = nS(tr == cluster(i, 2));
    %end  
    %cluster = cluster(nSpikes == burstCrit, :);
    selectedSpikes = IdentifyCaBurstsForSTA(cluster, burstSpike, burstCrit);
    cluster = cluster(selectedSpikes & (isnan(ISI) | (ISI > lockout & ISI < lockout2 & ISInext > successorLockout)), :);
    figure;
    raster(cluster);
    disp(['# of Ca++ bursts: ' num2str(nrows(cluster))]);
else
    % apply thalamic ISI lockout, if any
    if (lockout > 0 | lockout2 < Inf | successorLockout > 0)
        cluster = cluster(isnan(ISI) | (ISI > lockout & ISI < lockout2 & ISInext > successorLockout), :);
        disp(['spikes remaining after applying TC lockouts: ' num2str(nrows(cluster))]);
    end
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

% If UpDownBorder ends in 'p', it is a percentile not a request for a
% specific voltage. In this case, program determines corresponding voltage.
if strcmp(UpDownBorder(end:end), 'p')
    p1 = str2num(UpDownBorder(1:end-1));
    UpDownBorder = VmDistribution(averagingpath, duration, winstart, winend, trialStart, trialEnd, p1, 100-p1, false, true, 100);
else
    UpDownBorder = str2num(UpDownBorder);
end

% compute/plot the raw STA
[x, raw, nraw, isis, meanVm1, avgvar1] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, UpDownBorder, [], GreaterThan, memoryless, Plots);
ISIsRaw = isis;
meanVmRaw = meanVm1;

raw = raw - 7; % correct for jxn potential

h = figure;
whitebg('w');
figure(h);
if (ShiftCorrect) subplot(4,1,1); end
plot(x, raw);
line([0 0], ylim, 'Color', 'black');
box off;
ylabel('Vm');

global rawx;
global rawy;
rawx = x;
rawy = raw;

% compute a simple significance test of the post-thalamic Vm change
spon = raw(x > -25 & x < -5);
CI = 2.57 * std(spon) + raw(x == 1); % 99% 2-tailed CI
connected = sum(raw(x > 0.9 & x < 5) > CI) > 0;    
if (ShiftCorrect) subplot(4,1,1); end
line([min(x) max(x)], [CI CI], 'LineStyle', '--');

% compute/plot a shift corrector and a subtraction
if (ShiftCorrect)
    cluster(:,2) = cluster(:,2) + 1;

    [x, shift, nshift, isis2, meanVm2, avgvar] = SpikeTriggerAverage(duration, cluster, averagingpath, limit, UpDownBorder, [], GreaterThan, memoryless, Plots);
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
    
    % write corrected STA to a text file
    dlmwrite([averagingpath(1:(length(averagingpath)-4)) '-sta.txt'], [x; corrected]', '\t');
    
    % make available to workspace
    global stax
    global stay
    stax = x;
    stay = corrected; 
        
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
    psp = struct('amp', NaN, 'rt', NaN, 'peaktime', NaN, 'tau', NaN, 'latency', NaN);
    if (measurePSP)
        if (nargin < 21)
            [psp.amp, psp.rt, psp.peaktime, psp.tau, psp.latency] = MeasurePSP(stax, stay, false, 20);
        else
            [psp.amp, psp.rt, psp.peaktime, psp.tau, psp.latency] = MeasurePSP(stax, stay, false, 20, onset, offset);
        end
        title(['latency = ' num2str(psp.latency) ' ms, amplitude = ' num2str(psp.amp), ' mV, 20-80% RT = ' num2str(psp.rt) ' ms, tau = ' num2str(psp.tau) ' ms']);
    end
    
    % compute a simple significance test of the post-thalamic Vm change
    spon = corrected(x > -25 & x < -5);
    CI = 2.57 * std(spon) + corrected(x==0); % 99% 2-tailed CI
    subplot(4,1,3);
    line([min(x) max(x)], [CI CI], 'LineStyle', '--');
    subplot(4,1,4);
    line([-10 50], [CI CI], 'LineStyle', '--');
    connected = sum(corrected(x > 0.9 & x < 5) > CI) > 0;
    
    % in preparation for bootstrap, make cluster a global variable
    temp = cluster;
    global cluster;
    cluster = temp;
    
    % bootstrap confidence intervals by drawing random samples of *trials*
    global bootstat;
    bootstat = bootstrp(5000, bootstrapIterationOfSTA, trialStart:trialEnd, duration, averagingpath, limit, UpDownBorder, [], GreaterThan, Plots);    
    
else
    corrected = [];
    isis2 = NaN;
    meanVm2 = NaN;
    
    psp = struct('amp', NaN, 'rt', NaN, 'peaktime', NaN, 'tau', NaN, 'latency', NaN);
    if (measurePSP)
        if (nargin < 21)
            [psp.amp, psp.rt, psp.peaktime, psp.tau, psp.latency] = MeasurePSP(x, raw, false, 20);
        else
            [psp.amp, psp.rt, psp.peaktime, psp.tau, psp.latency] = MeasurePSP(x, raw, false, 20, onset, offset);
        end
        title(['latency = ' num2str(psp.latency) ' ms, amplitude = ' num2str(psp.amp), ' mV, 20-80% RT = ' num2str(psp.rt) ' ms, tau = ' num2str(psp.tau) ' ms']);
    end
    
    spon = raw(x > -25 & x < -5);
    CI = 2.57 * std(spon) + raw(x==0); % 99% 2-tailed CI
    connected = sum(raw(x > 0.9 & x < 5) > CI) > 0;
    
    nshift = nraw;
end

if ShiftCorrect
    spikestr = ['raw spikes: ' num2str(nraw) ', corrector spikes: ' num2str(nshift)];
    subplot(4,1,1);
else
    spikestr = ['raw spikes: ' num2str(nraw)];
end

if isinf(UpDownBorder)
    Vmstr = [];
else
    switch GreaterThan
        case 0
            Vmstr = [', Vm < ' num2str(signif(UpDownBorder, 1))];
        case 1
            Vmstr = [', Vm > ' num2str(signif(UpDownBorder, 1))];
        case 2
            Vmstr = [', ' num2str(signif(UpDownBorder, 1)) ' < Vm < ' num2str(Vend)];
    end
end

VandISIstr = ['mean ISI (raw spks) = ' num2str(signif(mean(excise(isis)), 1)) ...
    ', stderr = ' num2str(signif(stderr(isis), 1)) ...
    ', mean ISI (shift spks) = ' num2str(signif(mean(excise(isis2)), 1)) ...
    ', stderr = ' num2str(signif(stderr(isis2), 1)) ...
    ', mean Vm (raw) = ' num2str(signif(meanVm1, 1)) ...
    ', mean Vm (shift) = ' num2str(signif(meanVm2, 1))];

title(sprintf([strrep(triggerpath, '\', '\\') ...
    ', trials: ' num2str(trialStart) '-' num2str(max(cluster(:,2))) ...
    ', TC lockout: ' num2str(lockout) ...
    ', successor lockout: ' num2str(successorLockout) ...
    ', ' spikestr ...
    Vmstr ...
    '\n' VandISIstr ...
    '\nraw sta']));

orient landscape;
set(gcf, 'Name', averagingpath);
plotedit on;

disp(VandISIstr);
if ShiftCorrect
    ttest2(excise(isis), excise(isis2))
end
