function CorrectDrift(filepath, duration, winstart, winend)

% This function is intended to be used to correct non-biological DC drift.
% Only use this if you are sure that the drift is artifact (e.g., saline
% level has changed) because down/threshold/AP-peaks drift together and
% there are no apparent changes in Rs. BE CAREFUL!!!
%
% Assumes that a linear fit is sufficient to describe the drift, that
% there is sufficient data at the beginning and end of the dataset and
% that these periods are of an identical nature.
%
% Randy Bruno, February 2006

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 2)
    answers = inputdlg({'duration (msec)', 'window start (msec)', 'window end (msec)', 'epoch1 start', 'epoch1 end', 'epoch2 start', 'epoch2 end'}, ...
        'Parameters', 1, {'5000', '300', '5000', '0', '36', '80', '90'});
    duration = str2num(answers{1});
    winstart = str2num(answers{2});
    winend = str2num(answers{3});
    epoch1start = str2num(answers{4});
    epoch1end = str2num(answers{5});
    epoch2start = str2num(answers{6});
    epoch2end = str2num(answers{7});
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
SAMPLESPERMS = SAMPLERATE / 1000;
nScans = SAMPLERATE * (duration / 1000);
recSize = (nScans + 1) * 4; %in bytes
x = linspace(0, duration, SAMPLESPERMS*duration);

% Determine the mean Vm for each trial
fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);
Vmean = [];
nRecs = 0;
while (~feof(fid) & nRecs <= epoch2end)
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid)) break; end;
    signal = SCALINGFACTOR * fread(fid, nScans, 'float32');
    if (feof(fid)) break; end;
    excerpt = signal(x > winstart & x <= winend);
    Vmean = [Vmean, mean(excerpt)];
    nRecs = nRecs + 1;
end
fseek(fid, headerSize, 'bof');

% Determine linear fit
figure;
xx = 0:(length(Vmean)-1);
Vmean((epoch1end+2):(epoch2start)) = NaN;
plot(xx, Vmean);
b = linearAnalysis(Vmean, xx, true);
line(xx, xx*b(2)+b(1));

% Create output file
OutPath = [filepath(1:(length(filepath)-4)) '-corrected.dat']
oid = fopen(OutPath, 'w', 'b');
fprintf(oid, '%%%%ENDHEADER\n'); %writes %%ENDHEADER

% Correct
ntrials = 0;
figure;
while (~feof(fid) & ntrials <= epoch2end)
    % read stimulus code and whole-cell trace
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid) | isempty(stimulus)) break; end;
%     if (stimulus > -1)
%         errordlg('an invalid stimulus code. Check that correct datafile and trial duration have been selected.');
%         return
%     end   
    signal = SCALINGFACTOR * fread(fid, nScans, 'float32');
    if (feof(fid) | isempty(signal)) break; end;

    fsignal = signal - b(2) * ntrials;
    
    fwrite(oid, stimulus, 'float32'); % write stimulus code
    fwrite(oid, fsignal / SCALINGFACTOR, 'float32'); % and filtered data to psp file
    
    mi = min([signal; fsignal]);
    ma = max([signal; fsignal]);
    subplot(2,1,1);
    plot(signal);
    ylim([mi ma]);
    title(['record ' num2str(ntrials)]);
    subplot(2,1,2);
    plot(fsignal);
    ylim([mi ma]);

    drawnow;

    ntrials = ntrials + 1;
end
fclose(fid);
fclose(oid);
