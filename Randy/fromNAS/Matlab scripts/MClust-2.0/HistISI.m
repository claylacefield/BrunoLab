function [H, binsUsed] = HistISI(TS, varargin)

% H = HistISI(TS, parameters)
%
% INPUTS:
%      TS = a single ts object
%
% OUTPUTS:
%      H = histogram of ISI
%      N = bin centers
%
% PARAMETERS:
%     nBins 500
%
% If no outputs are given, then plots the figure directly.
%
% ADR 1998
% version L5.3
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m

%--------------------
if ~isa(TS, 'ts'); error('Type Error: input is not a ts object.'); end
epsilon = 1e-100;
nBins = 500;
Extract_varargin;

%--------------------
ISI = diff(Data(TS)/10) + epsilon;
if ~isreal(log10(ISI))
   warning('ISI contains negative differences; log10(ISI) is complex.');
   complexISIs = 1;
else
   complexISIs = 0;
end
maxLogISI = max(real(log10(ISI)))+1;
H = ndhist(log10(ISI)', nBins, 0, maxLogISI);
binsUsed = logspace(0,maxLogISI,nBins);

%-------------------
if nargout == 0
   plot(binsUsed, H);
   if complexISIs
      xlabel('ISI, ms.  WARNING: contains negative components.');
   else
      xlabel('ISI, ms');
   end
   set(gca, 'XScale', 'log');
   set(gca, 'XLim', [.5 10^(maxLogISI-1)]); %RMB
   set(gca, 'YTick', max(H));
end

   
   