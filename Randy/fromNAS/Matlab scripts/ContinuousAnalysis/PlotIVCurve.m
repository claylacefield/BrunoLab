function PlotIVCurve

duration = 1000;
stimonset = 100;
winstart = 200;
winend = 300;

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

figure;
[average, x, stim] = MeanContinuousByStim(filepath, duration, stimonset, false);

n = length(stim);
dV = zeros(n, 1);
V = zeros(n, 1);
for i = 1:n
    baseline = mean(average(x < stimonset, i));
    dV(i) = mean(average(x > winstart & x < winend, i)) - baseline;
    V(i) = mean(average(x > winstart & x < winend, i));
end

if iselement(-820, stim)
    %if using list file to inject currents
    for i = 1:n
        if stim(i) > -820
            stim(i) = abs(stim(i) + 800) * 100;
        end
        if stim(i) <= -820
            stim(i) = (stim(i) + 820) * 100;
        end
    end
else
    % paradigm file
    % stim codes are actual current injections in pA
end

figure;
subplot(2,1,1);
scatter(stim, dV);

stim
zeropos = find(stim == 0)
if isempty(zeropos)
    xx = stim(stim < 0);
    xx = xx(end);
    zeropos = find(stim == xx);
end
xx = [stim(zeropos-1) stim(zeropos+1)]
yy = [dV(zeropos-1) dV(zeropos+1)]
[b, bint, r, rint, stats] = linearAnalysis(yy, xx, false);
axis([min(stim) max(stim) min(dV) max(dV)]);
hold on;
xx = [-1000 1000];
line(xx, b(1)+b(2)*xx);
xlabel('injected current (pA)');
ylabel('voltage change (mV)');
title(['Ri using -100 and +100 pA = ' num2str(round(b(2)*1000)) ' MOhms']);

subplot(2,1,2);
scatter(stim, V);
xlabel('injected current (pA)');
ylabel('absolute voltage (mV)');
set(gcf, 'Name', filepath);