function PlotLFPbyStim()

% Written for Christine's LFP experiments (positive control for injection
% of ACh blockers)
%
% needs measure PeakAmplitudes.m
%
% Randy Bruno, September 2010

DURATION = 1000;
STIMONSET = 300;
WINSTART = 300;
WINEND = 325;

%% select datafiles
[filename pathname OK] = uigetfile('*.dat', 'Select pre-drug LFP file');
if (~OK) return; end
fp1 = [pathname, filename];

[filename2 pathname OK] = uigetfile('*.dat', 'Select drug LFP file');
if (~OK) return; end
fp2 = [pathname, filename2];

[filename3 pathname OK] = uigetfile('*.dat', 'Select recovery LFP file');
fp3 = [pathname, filename3];

nrecs = GetNumberOfRecords(fp1, DURATION);

% ask user for gain setting
answers = inputdlg({'amplifier gain (1 or 10)', 'Lynx gain (1-5000)'}, ...
    'enter gain settings', ...
    1, ... 
    {'1', '250'});
gainAmp = str2num(answers{1});
gainLynx = str2num(answers{2});

% average and plot all 3 datafiles
figure;
[average1, x1, stimuli1] = MeanContinuousByStim(fp1, DURATION, STIMONSET, false);
figure;
[average2, x2, stimuli2] = MeanContinuousByStim(fp2, DURATION, STIMONSET, false);
if OK
    figure;
    [average3, x3, stimuli3] = MeanContinuousByStim(fp3, DURATION, STIMONSET, false);
end

% measure peak amplitudes
% (MeanContinuousByStim has already scaled by 100 because it's normally dealing
% with a 10Vm output from Axoclamp. Scale factor of 10 here combined
% with amp gains below gets right units.)
[peak1, TimePtoBL1] = PeakAmplitudes(-average1*10, x1, stimuli1, STIMONSET, WINSTART, WINEND);
[peak2, TimePtoBL2] = PeakAmplitudes(-average2*10, x2, stimuli2, STIMONSET, WINSTART, WINEND);
if OK
    [peak3, TimePtoBL3] = PeakAmplitudes(-average3*10, x3, stimuli3, STIMONSET, WINSTART, WINEND);
end

figure;
% RMB calculated velocities from IR circuit measurements of stimulator movement
velocity = [1358 639 388 252 136];
plot(velocity, peak1/gainAmp/gainLynx, 'go-');
hold on;
plot(velocity, peak2/gainAmp/gainLynx, 'y^-');
if OK
    plot(velocity, peak3/gainAmp/gainLynx, 'rs-');
end
hold off;
box off;
y = ylim;
ylim([0 y(2)]);
xlabel('actual peak stimulator velocity (deg/sec)');
ylabel('peak LFP amplitude (mV)');
set(gca, 'color', 'black');
if OK
    title([fp1 ', ' filename2 ', ' filename3]);
else
    title([fp1 ', ' filename2]);
end

% PeakToBaselineTime vs velocity
% figure;
% plot(velocity, TimePtoBL1, 'go-');
% hold on;
% plot(velocity, TimePtoBL2, 'y^-');
% if OK
%     plot(velocity, TimePtoBL3, 'rs-');
% end
% hold off;
% box off;
% xlabel('actual peak stimulator velocity (deg/sec)');
% ylabel('time from peak to return to baseline (ms)');
% set(gca, 'color', 'black');
% if OK
%     title([fp1 ', ' filename2 ', ' filename3]);
% else
%     title([fp1 ', ' filename2]);
% end
