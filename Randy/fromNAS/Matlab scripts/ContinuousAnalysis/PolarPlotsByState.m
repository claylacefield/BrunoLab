function [AngleDiffSpikes, AngleDiffPSP] = PolarPlotsByState(filepath, duration, stimOnset, winstart, winend, OffStart, Plots, trialStart, trialEnd)
% Compute sub- and supra-threshold polar plots according to hyp./dep. state
%
% Randy Bruno, May 2004

if nargin == 0
    [filename pathname OK] = uigetfile('-wcp-psp.dat', 'Select filtered PSP file');
    if (~OK) return; end
    filepath = [pathname, filename];
else
    if (~exist(filepath, 'file'))
        disp(['PolarPlots.m cannot find ' filepath]);
        error(['PolarPlots.m cannot find ' filepath]);
        break
    end  
    
    %if this is not the psp file, change the filename to point to the psps
    if (isempty(findstr('psp', filepath)))
        filepath = [filepath(1:(length(filepath)-4)) '-psp.dat'];
    end
    
    %check that file exists
    if (~exist(filepath, 'file'))
        disp(['PolarPlots.m cannot find ' filepath]);
        error('Whole-cell recordings must first be separated into PSPs and spikes before being displayed as polar plots.');
        return
    end   
end

if (nargin < 5)
    answers = str2num(cell2mat(inputdlg({'Duration (msec)', 'Stimulus onset (msec)', 'Window Start (msec)', 'Window End (msec)', 'Off WindowStart (msec)'}, 'Parameters for polar plots', 1, {'500', '145', '150', '300', '350'})));
    duration = answers(1);
    stimOnset = answers(2);    
    winstart = answers(3);
    winend = answers(4);
    OffStart = answers(5);
end

if nargin < 7
    Plots = true;
end

if nargin < 9
    trialStart = 0;
    trialEnd = 100000;
end

stimuli = ReverseArray(GetStimCodes(filepath, duration))
nStim = length(stimuli);
if nStim == 1 | nStim > 16
    errordlg(['Parameters may be misconfigured. ' num2str(nStim) ' stimuli types detected.']);
    return
end

[prc1, prc2] = VmDistribution(filepath, duration, stimOnset-5, stimOnset, trialStart, trialEnd, 25, 75, false, false, 1, 'mean');
prc1 = prc1 - 7;
prc2 = prc2 - 7;

SCALINGFACTOR = 100;
SAMPLERATE = 32000; % in Hz
nScans = SAMPLERATE * (duration / 1000);
x = linspace(0, duration, nScans);
recSize = (nScans + 1) * 4; %in bytes

% load spike data
SpikePath = [filepath(1:(length(filepath)-7)) 'spikes.cluster1'];
cluster = ReadCluster(SpikePath);
cluster = cluster(cluster(:,2) >= trialStart & cluster(:,2) <= trialEnd, :);
trials = cluster(:,2);
degrees = StimCodeToDegrees(cluster(:,3));
nreps = (max(cluster(:,2)) - min(cluster(:,2)) + 1) / nStim;
timestamp = cluster(:,4);

% open PSP file
fid = fopen(filepath, 'r', 'b');
headerSize = SkipHeader(fid);

% average each condition separately
nUp = zeros(nStim, 1); % number of reps run for each stimulus
averageUp = zeros(nScans, nStim); % for holding memoryless averages of the traces (by stim)
pspUpOn = zeros(nStim, 1); % for holding memoryless averages of the PSP amplitudes
pspUpOff = zeros(nStim, 1); % for holding memoryless averages of the PSP amplitudes
spikesUpOn = zeros(nStim, 1);
spikesUpOff = zeros(nStim, 1);

nDown = zeros(nStim, 1); % number of reps run for each stimulus
averageDown = zeros(nScans, nStim); % for holding memoryless averages of the traces (by stim)
pspDownOn = zeros(nStim, 1); % for holding memoryless averages of the PSP amplitudes
pspDownOff = zeros(nStim, 1); % for holding memoryless averages of the PSP amplitudes
spikesDownOn = zeros(nStim, 1);
spikesDownOff = zeros(nStim, 1);

psps = []; % array of all amplitudes
slope = [];
stim = [];
trial = 0;
while (~feof(fid))
    stimulus = fread(fid, 1, 'float32');
    if (feof(fid) | isempty(stimulus)) break; end;
    signal = SCALINGFACTOR * fread(fid, nScans, 'float32') - 7;
    if (feof(fid) | isempty(signal)) break; end;
    if (trial >= trialStart) & (trial <= trialEnd)
        i = PositionInArray(stimuli, stimulus);        

        spikesOn = length(degrees(timestamp>=winstart & timestamp<winend & trials==trial));
        spikesOff = length(degrees(timestamp>=OffStart & timestamp<OffStart+(winend-winstart) & trials==trial));

        excerptMeanVm = mean(signal(x > stimOnset - 5 & x < stimOnset));
        if excerptMeanVm < prc1
            nDown(i) = nDown(i) + 1;
            averageDown(:, i) = MemorylessAverage(averageDown(:, i), signal, nDown(i));
            spikesDownOn(i) = spikesDownOn(i) + spikesOn;
            spikesDownOff(i) = spikesDownOff(i) + spikesOff;
        end
        if excerptMeanVm > prc2
            nUp(i) = nUp(i) + 1;
            averageUp(:, i) = MemorylessAverage(averageUp(:, i), signal, nUp(i));
            spikesUpOn(i) = spikesUpOn(i) + spikesOn;
            spikesUpOff(i) = spikesUpOff(i) + spikesOff;          
        end
        
    end
    trial = trial + 1;
end
fclose(fid);
spikesDownOn = spikesDownOn ./ nDown;
spikesDownOff = spikesDownOff ./ nDown;
spikesUpOn = spikesUpOn ./ nUp;
spikesUpOff = spikesUpOff ./ nUp;

if (Plots)
    figure;
    % plot averages of .psp.dat signals
    minimum = min([min(nonzeros(averageDown)) min(nonzeros(averageUp))]);
    maximum = max([max(nonzeros(averageDown)) max(nonzeros(averageUp))]);
    for i = 1:nStim
        subplot(nStim, 4, (i-1)*4 + 1);
        plot(x, averageDown(:, i));
        set(gca, 'Box', 'Off');
        axis([0 duration minimum maximum]);
        line([stimOnset stimOnset], [minimum, maximum], 'Color', 'green');
        if (i == 1)
            title('Down');
        end      
        if (i < nStim)
            set(gca, 'XTickLabel', '');
            xlabel('');
        end
        if (i == floor(nStim/2))
            ylabel('mean Vm');
        end
        
        subplot(nStim, 4, (i-1)*4 + 3);
        plot(x, averageUp(:, i));
        set(gca, 'Box', 'Off');
        axis([0 duration minimum maximum]);
        line([stimOnset stimOnset], [minimum, maximum], 'Color', 'green');
        if (i == 1)
            title('Up');
        end
        if (i < nStim)
            set(gca, 'XTickLabel', '');
            xlabel('');
        end
        if (i == floor(nStim/2))
            ylabel('mean Vm')
        end

    end
    xlabel('msec');
end

stimuli = StimCodeToDegrees(stimuli);
xx = stimuli' * pi / 180;

if (Plots)
    figure;
    % PSP amplitude polar plot
    subplot(3, 3, 1);   
    baselines = mean(averageUp(x > stimOnset - 5 & x < stimOnset, :), 1)';
    peaks = max(averageUp(x > winstart & x < winstart + 50, :), [], 1)';
    UpOn = peaks - baselines;  
    polar([xx; xx(1)], [UpOn; UpOn(1)]); %extra points are needed to prevent breaks in polar plots
    [angle1, magnitude, sumx, sumy] = meanVector(UpOn, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Up mean PSP (mV)');
    title('ON Response');
 
    subplot(3, 3, 2);   
    baselines = mean(averageUp(x > OffStart - 5 & x < OffStart, :), 1)';
    peaks = max(averageUp(x > OffStart & x < OffStart + 50, :), [], 1)';
    UpOff = peaks - baselines;  
    polar([xx; xx(1)], [UpOff; UpOff(1)]); %extra points are needed to prevent breaks in polar plots
    [angle, magnitude, sumx, sumy] = meanVector(UpOff, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Up mean PSP (mV)');
    title('OFF Response');
    
    subplot(3, 3, 3);
    yy = UpOff ./ UpOn;
    polar([xx; xx(1)], [yy; yy(1)]);
    title(['mean Off/On ratio = ' num2str(mean(yy))]);
    
    subplot(3, 3, 4);   
    baselines = mean(averageDown(x > stimOnset - 5 & x < stimOnset, :), 1)';
    peaks = max(averageDown(x > winstart & x < winstart + 50, :), [], 1)';
    DownOn = peaks - baselines;  
    polar([xx; xx(1)], [DownOn; DownOn(1)]); %extra points are needed to prevent breaks in polar plots
    [angle2, magnitude, sumx, sumy] = meanVector(DownOn, stimuli');
    AngleDiffPSP = angle2 - angle1;
    line([0 sumx], [0 sumy]);
    ylabel('Down mean PSP (mV)');
    title('ON Response');
 
    subplot(3, 3, 5);   
    baselines = mean(averageDown(x > OffStart - 5 & x < OffStart, :), 1)';
    peaks = max(averageDown(x > OffStart & x < OffStart + 50, :), [], 1)';
    DownOff = peaks - baselines;  
    polar([xx; xx(1)], [DownOff; DownOff(1)]); %extra points are needed to prevent breaks in polar plots
    [angle, magnitude, sumx, sumy] = meanVector(DownOff, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Down mean PSP (mV)');
    title('OFF Response');
    
    subplot(3, 3, 6);
    yy = DownOff ./ DownOn;
    polar([xx; xx(1)], [yy; yy(1)]);
    title(['mean Off/On ratio = ' num2str(mean(yy))]);
    
    subplot(3, 3, 7);
    yy = UpOn ./ DownOn;
    polar([xx; xx(1)], [yy; yy(1)]);
    ylabel('Up/Down ratios');
    
    subplot(3, 3, 8);
    yy = UpOff ./ DownOff;
    polar([xx; xx(1)], [yy; yy(1)]);
    
    set(gcf, 'Name', filepath);
    plotedit('ON');
    close;
    close;
    
    figure;
    % spikes polar plots
    subplot(3, 3, 1);
    polar([xx; xx(1)], [spikesUpOn; spikesUpOn(1)]); %extra points are needed to prevent breaks in polar plots
    [angle1, magnitude, sumx, sumy] = meanVector(spikesUpOn, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Up spikes/stim');
    title(sprintf([strrep(filepath, '\', '\\') '\nON Response']));
    
    subplot(3, 3, 2);   
    polar([xx; xx(1)], [spikesUpOff; spikesUpOff(1)]); %extra points are needed to prevent breaks in polar plots
    [angle, magnitude, sumx, sumy] = meanVector(spikesUpOff, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Up spikes/stim');
    title('OFF Response');
    
    subplot(3, 3, 4);   
    polar([xx; xx(1)], [spikesDownOn; spikesDownOn(1)]); %extra points are needed to prevent breaks in polar plots
    [angle2, magnitude, sumx, sumy] = meanVector(spikesDownOn, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Down spikes/stim');
    title('ON Response');
    AngleDiffSpikes = angle2 - angle1;
    
    subplot(3, 3, 5);   
    polar([xx; xx(1)], [spikesDownOff; spikesDownOff(1)]); %extra points are needed to prevent breaks in polar plots
    [angle, magnitude, sumx, sumy] = meanVector(spikesDownOff, stimuli');
    line([0 sumx], [0 sumy]);
    ylabel('Down spikes/stim');
    title('OFF Response');    
end
