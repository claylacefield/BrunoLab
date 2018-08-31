function CheckCluster(fn, WV, StartingTime, EndingTime)

% CheckCluster(fn, WV, StartingTime, EndingTime)
%
% INPUTS
%    fn: filename of cluster file
%    WV: tsd of selected TT
%
% OUTPUTS : none
%
% Shows key points of cluster
%
% ADR 1998
% version L1.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

T = Range(WV, 'ts');
if isempty(T)
   return
end

WVD = Data(WV);

figure('Name', fn, 'NumberTitle', 'Off');
clf
colormap(1-gray);
nPlot = 2;
mPlot = 2;

% PLOT: AvgWaveform
subplot(nPlot,mPlot,1);
for it = 1:4
  mWV = squeeze(mean(WVD(:,it,:),1));
  sWV = squeeze(std(WVD(:,it,:),1));
  xrange = (34 * (it-1)) + (1:32); 
  hold on;
  plot(xrange, mWV);
  errorbar(xrange,mWV,sWV); 
end
axis off
axis([0 140 -2100 2100])
title('Average Waveform');
hold off
drawnow

% PLOT: ISIStats (text)
subplot(nPlot, mPlot, 2);
nmsgs = 1;
msgstr = {fn};
nmsgs = nmsgs+1;

if isempty(getenv('USER'))
   msgstr{nmsgs} = sprintf('Cut on %s', date);
else   
   msgstr{nmsgs} = sprintf('Cut by %s on %s', getenv('USER'), date);
end
nmsgs = nmsgs+1;

nSpikes = length(Data(T));
msgstr{nmsgs} = sprintf('%d spikes ', nSpikes);
nmsgs = nmsgs+1;

mISI = mean(diff(Data(T)));
fr = 10000 * nSpikes/(EndingTime - StartingTime);
msgstr{nmsgs} = sprintf('firing rate = %.4f spikes/sec ', fr);
nmsgs = nmsgs+1;

sw = SpikeWidth(WV);
mSW = mean(sw,1);
vSW = std(sw, 1);
msgstr{nmsgs}   = sprintf('spikewidth (Ch1,2) = %4.2f +/- %4.2f   %4.2f +/- %4.2f', ...
   mSW(1), vSW(1), mSW(2), vSW(2));
msgstr{nmsgs+1} = sprintf('spikewidth (Ch3,4) = %4.2f +/- %4.2f   %4.2f +/- %4.2f', ...
   mSW(3), vSW(3), mSW(4), vSW(4));
nmsgs = nmsgs+2;

p2v = PeakToValley(WV);
mp2v = mean(p2v,1);
vp2v = std(p2v,1);
msgstr{nmsgs}   = sprintf('peak/valley (Ch1,2) = %4.2f +/- %4.2f    %4.2f +/- %4.2f', ...
   mp2v(1), vp2v(1), mp2v(2), vp2v(2));
msgstr{nmsgs+1} = sprintf('peak/valley (Ch3,4) = %4.2f +/- %4.2f    %4.2f +/- %4.2f', ...
   mp2v(3), vp2v(3), mp2v(4), vp2v(4));
nmsgs = nmsgs+2;

text(0,0.5, msgstr);
axis off
drawnow

% PLOT: HistISI
subplot(nPlot, mPlot, 3);
HistISI(T);
title('histogram of log(ISI)')
ylabel('nSpikes');
drawnow

return
% PLOT: AutoCorr
subplot(nPlot, mPlot, 4);
[acorr,lags] = autocorr(T, 100, 5000);
acorr(floor(length(acorr)/2+1)) = 0;    % set 0 lag to 0 for scaling
bar(lags/10000, acorr);			% show acorr
H = findobj(gca, 'Type', 'patch');
set(H, 'facecolor', [0 0 0])
title('autocorrelation')
drawnow

