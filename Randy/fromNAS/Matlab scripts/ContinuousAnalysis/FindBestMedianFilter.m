function FilterSize = FindBestMedianFilter(filepath, duration)

if (nargin == 0)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    filepath = [pathname, filename];
end

if (nargin < 2)
    answers = str2num(cell2mat(inputdlg({'duration (msec)'}, 'Parameters', 1, {'500'})));
    duration = answers(1);
end

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
x = linspace(0, duration, nScans);
recSize = (nScans + 1) * 4; %in bytes

fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

FilterSize = 4; % start with a 4-msec filter

set(gcf, 'Units', 'normalized');
set(gcf, 'Position', [0.1 0.05 0.8 0.85]);

n = 0;
while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid) | isempty(stimulus)) break; end;
    signal = fread(fid, nScans, 'float32') * SCALINGFACTOR;
    if (feof(fid) | isempty(signal)) break; end;

    fsignal = medfilt1(signal, SAMPLERATE/1000 * FilterSize);
    minimum = min([signal; fsignal]);
    maximum = max([signal; fsignal]);

    subplot(5,1,1);
    plot(x, signal);
    ylim([minimum maximum]);
    title([filepath ', record #' num2str(n)]);
    subplot(5,1,2);
    plot(x, fsignal);
    ylim([minimum maximum]);
    title([num2str(FilterSize) '-msec median-filtered signal']);
    subplot(5,1,3);
    plot(x, signal-fsignal);
    title('spikes');

    % plot filtered signal around first spike, if any, or peak PSP
    time = threshold((signal - fsignal), 10, 64) / (SAMPLERATE / 1000);
    if (isempty(time))
        time = find(signal==max(signal)) / (SAMPLERATE / 1000);
    end
    if (time(1) > 25)
        posstart = (time(1) - 25) * SAMPLERATE/1000;
    else
        posstart = 2; % scan 2
    end
    if (time(1) < (duration-25))
        posend = (time(1) + 25) * SAMPLERATE/1000;
    else
        posend = nScans; % last scan
    end

    subplot(5,1,4);
    plot(x(posstart:posend), signal(posstart:posend));
    axis([x(posstart) x(posend) minimum maximum]);
    title('zoom on first spike or max');
    
    subplot(5,1,5);
    plot(x(posstart:posend), fsignal(posstart:posend));
    axis([x(posstart) x(posend) minimum maximum]);
    title('median filtered');
        
    answers = cell2mat(inputdlg({'new filter size (msec); click CANCEL to end'}, 'Parameters', 1, {num2str(FilterSize)}));
    
    if (isempty(answers))
        break;
    else
        answers = str2num(answers);
        if (FilterSize ~= answers(1))
            FilterSize = answers(1);
            if (ftell(fid) >= headerSize + recSize)
                fseek(fid, -recSize, 'cof');
            end
        end
    end

    n = n + 1;
end

fclose(fid);
