function PowerSpectrum(filepath, duration)

if (nargin == 0)
    [filename pathname OK] = uigetfile('.dat', 'Select .dat file');
    if (~OK) return; end
    filepath = [pathname, filename];
    duration = 500;
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

fseek(fid, 0, 'eof');
fileSize = ftell(fid);
nRecs = (fileSize - headerSize) / recSize;
fseek(fid, headerSize, 'bof');

signal = zeros(nRecs * nScans, 1);
x = linspace(0, duration, nScans);
data = nans(nScans, nRecs);
for i = 1:nRecs
    stimulus = fread(fid, 1, 'float32');

    data(:,i) = fread(fid, nScans, 'float32');
    
    [Pxx,f] = pwelch(data(x > 155 & x < 255,i),(255-155)*32/10,[],[],SAMPLERATE);
end

% params.pad = 2;
% params.Fs = SAMPLERATE;
% params.fpass = [1 1000];
% params.trialave = 1;
% params.tapers = [5 4];
% [S,f]=mtspectrumc(data,params);

figure;
plot(f, Pxx);
xlim([0 200]);