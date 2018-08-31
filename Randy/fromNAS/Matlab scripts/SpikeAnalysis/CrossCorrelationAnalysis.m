function [strength, Npre, coherence] = CrossCorrelationAnalysis(clusterA, clusterB, winstart, winend, trialstart, trialend, limits, binsize, ShiftCorrect, interpolate, ignore)

SYNCHRONYWINDOW = 20;
NORM = true;

% Randy Bruno, March 2006

% excerpt specified time window
clusterA = clusterA(clusterA(:,4) >= winstart & clusterA(:,4) < winend, :);
clusterB = clusterB(clusterB(:,4) >= winstart & clusterB(:,4) < winend, :);
%only necessary to select trigger spikes (clusterB)

% excerpt specified trials
clusterA = clusterA(clusterA(:,2) >= trialstart & clusterA(:,2) < trialend, :);
clusterB = clusterB(clusterB(:,2) >= trialstart & clusterB(:,2) < trialend, :);

% compute/plot the raw ccg
[raw, x] = CrossCorrelate(clusterA, clusterB, limits, binsize, NORM);

if interpolate
    raw(x >= -interpolate & x < interpolate) = mean([raw(x >= -(interpolate+1) & x < -interpolate) raw(x > interpolate & x <= (interpolate+1))]);
end
if ignore
    raw(x >= -ignore & x < ignore) = NaN;
end
if (ShiftCorrect) subplot(3,1,1); end
%raw = conv(raw, gausswin(3));
plot(x, raw);
line([0 0], ylim, 'Color', 'black'); 

% compute correlation strength according to Alonso & Martinez 1998
baseline = mean(raw((x > -(SYNCHRONYWINDOW+10) & x < -(SYNCHRONYWINDOW+5)) | ...
                    (x > (SYNCHRONYWINDOW+5) & x < (SYNCHRONYWINDOW+10))));
%baseline = mean(raw(x < -(SYNCHRONYWINDOW+5) | x > (SYNCHRONYWINDOW+5)));
line([-limits limits], [baseline baseline]);
Nc = sum(excise(raw(x > -SYNCHRONYWINDOW & x < SYNCHRONYWINDOW) - baseline));
Npre = nrows(clusterB);
Npost = nrows(clusterA);
strength = Nc / (sqrt(Npre^2 + Npost^2) / 2);

title(['raw ccg, ' num2str(Npre) ' trigger spikes, strength = ' num2str(strength)]);
box off;

% compute/plot a shift corrector and a subtraction
if (ShiftCorrect)
    maxTrial = max(clusterB(:,2));
    clusterB = clusterB(clusterB(:,2) ~= maxTrial, :);
    clusterB(:,2) = clusterB(:,2) + 1;

    [shift, x] = CrossCorrelate(clusterA, clusterB, limits, binsize, NORM);
    subplot(3,1,2);
    plot(x, shift);
    line([0 0], ylim, 'Color', 'black'); 
    title('shift corrector');
    box off;
    
    corrected = raw - shift;
    subplot(3,1,3);
    plot(x, corrected);
    line([0 0], ylim, 'Color', 'black'); 
    xlabel('lag (msec)');
    box off;
    
    confLimits = 3.3 * sqrt(shift);
    line(x, confLimits);
    line(x, -confLimits);
    
    title(['corrected CCG']);
end

plotedit on;

% Compute coherence analysis
data1 = ConvertClusterToChronux(clusterA);
data2 = ConvertClusterToChronux(clusterB);
if ncols(data1) > ncols(data2)
    data2(ncols(data1)).timestamps = [];
end
if ncols(data2) > ncols(data1)
    data1(ncols(data2)).timestamps = [];
end

params.err = [2 0.05];
params.trialave = 1;
params.fpass = [1 200];
params.Fs = 32000;
[C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=coherencypt(data1,data2,params);
figure;
subplot(3,1,1);
plot(f,S1);
title('power spectrum of cell 1');
subplot(3,1,2);
plot(f,S2);
title('power spectrum of cell 2');
subplot(3,1,3);
plot(f,C)
hold on;
plot(f, Cerr);
coherence = mean(C(f < 20));
title(['coherence, mean coherence 1-20 Hz: ' num2str(coherence)]);
xlabel('Hz');



