% Batch process a list of files contained in a spreadsheet databases.
% Only for spikes.
% Batch Population Polar Plots
% Randy Bruno, October 2004
function BatchPopPolarPlot(PW, rotated, winStart, winEnd, Plots)

n = length(PW);

spontaneous = zeros(n, 1);
spikesmean = zeros(n, 1);
spikespref = zeros(n, 1);
bestAngle = zeros(n, 1);
avgspikes = zeros(8,1);
ravgspikes = zeros(8,1);
ncells = 0;
nspikingcells = 0;
for i = 1:n
    disp(['i = ', num2str(i), ': ', PW{i}]);
    if (~isempty(PW{i}) & ~strcmp(PW{i}, 'NA'))
        % if there is a PW file listed...
        
        f = PW{i};
        % for whole-cell data
        %f = [f(1:30) '-spikes.cluster1'];
        
        % for old Pittsburgh files and others?
        %f = ['D' f(2:end)];
        
        %if (~exist(f))
        	%g = [f(1:end-22) f(end-7:end)]
			%if ~exist(f)
				%g = [f(1:end-21) f(end-7:end)]
                %if ~exist(g)
                %    continue
                %end
                %end
            %f = g
            %end

        if (~exist(f, 'file'))
            error(['BatchPopPolarPlot.m cannot find ' f]);
            break
        end  
        
        cluster = ReadCluster(f);
        [nspikes, stimuli, spon] = PolarSpikes(cluster, winStart, winEnd, [], Plots);
        if (length(nspikes) == 8)        
        ncells = ncells + 1;
       
        spontaneous(i) = spon;
        spikesmean(i) = mean(nspikes);
        spikespref(i) = max(nspikes);
        
        % correct for stimulator rotation if necessary
        disp(rotated);
        if (~isnan(rotated(i)) & rotated(i))
            disp('rotated')
            shift = rotated(i) / 45;
            nspikes = circshift(nspikes, shift);
        end         
            
        %average polar plots
        if (max(nspikes) > 0)
            nspikingcells = nspikingcells + 1;
            avgspikes = MemorylessAverage(avgspikes, nspikes, nspikingcells);
            bestAngleSpikes = stimuli(nspikes==max(nspikes));
            ravgspikes = MemorylessAverage(ravgspikes, circshift(nspikes, -bestAngleSpikes/45), nspikingcells);
        end
        figure(1);
        subplot(2, 2, 2);
        polar(DegreesToRadians([stimuli; stimuli(1)]), [avgspikes; avgspikes(1)]);
        title(['Average polar plot (n = ' num2str(nspikingcells) ')']);
        drawnow;
        
        %average polar plots aligned to best direction
        figure(1);
        subplot(2, 2, 4);
        polar(DegreesToRadians([stimuli; stimuli(1)]), [ravgspikes; ravgspikes(1)]);
        title(['Rotated to best angle']);
        drawnow;
        end
    else
        spontaneous(i) = NaN;
        spikesmean(i) = NaN;
        spikespref(i) = NaN;
        bestAngle(i) = NaN;
    end
end
