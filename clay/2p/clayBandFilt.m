% BandFilt v.1.0
%
% Usage: [Filtered,FiltHilb,FiltAmp,FiltPh] = BandFilt(eeg,sampFreq,low,high);
%
%
%
% 

function [Filtered,FiltHilb,FiltAmp,FiltPh] = clayBandFilt(eeg,sampFreq,low,high);

% check inputs
if (nargin~=4), fprintf('\nUsage:\n[Filtered,FiltHilb,FiltAmp,FiltPh] = BandFilt(eeg,sampFreq,filttype\n);'); return; end;


Nyquist = floor(sampFreq/2);

order = round(sampFreq);
if mod(order,2)~= 0
    order = order-1;
end

MyFilt=fir1(order,[low high]/Nyquist);


%fprintf('\nFiltering...\n');%
Filtered = filtfilt(MyFilt,eeg);

if (nargout>1)
    FiltHilb = hilbert(Filtered);
    FiltPh = angle(FiltHilb);
    FiltAmp = abs(FiltHilb);
end
