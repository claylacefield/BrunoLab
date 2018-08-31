function [response, n] = QuantalHist(duration, triggercluster, averagingpath, LIMIT, UpDownBorder, Vend, GreaterThan)
% QUANTALHIST Measure the amplitudes of PSPs from one cell evoked by spikes
% from a second cell.
%
% Adapted from SpikeTriggerAverage.m
%
% INPUTS
% duration: trial length in msecs
% triggercluster: a standard matrix description of a cluster of spikes
%                   corresponding to one cell
% averagingpath: a string specifying the filepath of a continuous datafile
%               to be averaged
% LIMIT: # of msecs around a spiketime to average the continuous trace
% UpDownBorder: mV above which the cortical cell is said to be in an UP
%               state and below which the cell is in a DOWN state
% Vend: can be used with UpDownBorder to define a specific range of mV to
%       examine (only has an effect when GreaterThan = 2)
% GreaterThan: set to 1 to average only data having Vm > UpDownBorder, 0
%               for <, and 2 for UpDownBorder < Vm < Vend
%
% OUTPUTS
% x: an array of pre-/post-spiketimes spanning -LIMIT to +LIMIT
% average: the spike-triggered average at times specified by x
% n: a single integer giving the # of spikes used in computing the STA
%
% Randy Bruno, December 2003

if (nargin < 4)
    LIMIT = 20;
    UpDownBorder = -60;
    GreaterThan = 0;
end

if (nargin < 2)
    triggercluster = ReadCluster;
end

if (nargin < 3)
    [filename pathname OK] = uigetfile('*.dat', 'Select continuous signal file');
    if (~OK) return; end
    averagingpath = [pathname, filename];
end

SAMPLERATE = 32000; % in Hz
VpreSpikeStart = SAMPLERATE/1000 * (LIMIT - 5);
VpreSpikeEnd = SAMPLERATE/1000 * LIMIT;
VpostSpikeStart = SAMPLERATE/1000 * (LIMIT + 4);
VpostSpikeEnd = SAMPLERATE/1000 * (LIMIT + 6);
recSize = (SAMPLERATE * (duration / 1000) + 1) * 4; %in bytes

trial = triggercluster(:,2);
stimcode = triggercluster(:,3);
timestamp = triggercluster(:,4);

fid = fopen(averagingpath, 'r', 'b');
headerSize = SkipHeader(fid);

nScansToRead = SAMPLERATE/1000 * LIMIT * 2 + 1;
x = linspace(-LIMIT, LIMIT, nScansToRead);

disp('Computing quantal histogram...');
n = 0;
response = [];
lasttrial = 0;
for i = 1:length(timestamp)
    if (timestamp(i) > 0) % don't read null spikes!
        if (timestamp(i) >= LIMIT & timestamp(i) < (duration-LIMIT)) % must have long enough periods to average
            % change position to start of appropriate continuous record &
            % get stimcode
            status = fseek(fid, trial(i)*recSize + headerSize, 'bof');
            if (status == -1) error('could not seek to start of record'); end
            stimulus = fread(fid, 1, 'float32');
            if (stimulus ~= stimcode(i))
                error(['Stimulus codes (' num2str(stimulus) ' and ' num2str(stimcode(i)) ') do not match. Check specified value for trial duration.']);
            end
            % change position to start of appropriate period to sample
            ByteOffset = round((timestamp(i) - LIMIT) * SAMPLERATE/1000) * 4;
            status = fseek(fid, ByteOffset, 'cof');
            if (status == -1) error('could not seek to appropriate position'); end
            % sample
            data = fread(fid, nScansToRead, 'float32')';
            if max(data) > .99 % if data acquisition voltage limits were exceeded, skip this sample -- trick to avoid electrical noise artifacts
                continue
            end
            data = data * 100; % put Vm on mV scale
            if (~feof(fid)) % average for each spike; ignore spikes near the end of spontaneous recording
                baseline = mean(data(VpreSpikeStart:VpreSpikeEnd));
                if ((GreaterThan==1 & baseline > UpDownBorder) | (GreaterThan==0 & baseline < UpDownBorder) | (GreaterThan==2 & baseline> UpDownBorder & baseline < Vend))
                    figure(1);
                    plot(x, data);
                    drawnow;
                    set(gcf, 'Units', 'normalized', 'Position', [.5 .5 .4 .4]);
                    OK=questdlg('Continue?', '', 'Yes', 'No', 'Yes');
                    if (strcmp(OK, 'No'))
                        return
                    end
                    n = n + 1;
                        % MEASURE PSP HERE
                        amplitude = mean(data(VpostSpikeStart:VpostSpikeEnd)) - baseline;
                        response = [response, amplitude];
                end
            end
        end
    end
end
fclose(fid);
disp(['Computed histogram using ', num2str(n), ' of a possible ', num2str(length(timestamp)), ' real/null records']);
%hist(response, 500);
