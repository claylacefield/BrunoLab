function [mWV, sWV] = AverageWaveform(WV)

% AverageWaveform(wv)
%
%
% INPUTS
%    wv -- tsd of tt or waveform data
%
% OUTPUTS
%    mWV - mean waveform 4 x 32
%    sWV - stddev waveform 4 x 32
%
%
% ADR 1998
% version L4.1
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

mWV = zeros(4,32);
sWV = zeros(4,32);

WVD = Data(WV);
mWV = squeeze(mean(WVD,1));
sWV = squeeze(std(WVD,1));

if nargout == 0   % no output args, plot it
   for it = 1:4
      xrange = (34 * (it-1)) + (1:32); 
      hold on;
      plot(xrange, mWV(it,:));
      errorbar(xrange,mWV(it,:),sWV(it,:)); 
   end
   axis off
   axis([0 140 -2100 2100])
   title('Average Waveform');
   hold off
end