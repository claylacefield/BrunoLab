% Batch process a list of files contained in a spreadsheet databases.
% Is there a match/mismatch between preferred direction during ON, plateau,
% and OFF?
% Randy Bruno, October 2004

% fix answers so don't have to be 3 digits
data = xlsreadastext('C:\Documents and Settings\Randy Bruno\Desktop\analyses\fentanyl.xls'); %read data
attach;

n = length(Pwfile);

pspmean = zeros(n, 1);
psppref = zeros(n, 1);
spontaneous = zeros(n, 1);
spikesmean = zeros(n, 1);
spikespref = zeros(n, 1);
bestAngle = zeros(n, 1);
avgVectorAngle = zeros(n, 1);
avgVectorMag = zeros(n, 1);
avgpsp = zeros(8,1);
avgspikes = zeros(8,1);
ravgpsp = zeros(8,1);
ravgspikes = zeros(8,1);
ncells = 0;
nspikingcells = 0;
for i = 1:n
    disp(['i = ', num2str(i), ': ', Pwfile{i}]);
    if (~isempty(Pwfile{i}) & ~strcmp(Pwfile{i}, 'NA') & isfinite(medfilt(i)) & ~strcmp(fp(i), 'FS'))
        % if there is a PW file listed and the data was filterable...

        ncells = ncells + 1;
        
        [psp, ONspikes, stimuli, spon] = PolarPlots(Pwfile{i}, 500, 145, 150, 200, false);
        [psp, platspikes, stimuli, spon] = PolarPlots(Pwfile{i}, 500, 145, 200, 350, false);
        stimuli = stimuli';
       
        %pspmean(i) = mean(psp);
        %psppref(i) = max(psp);
        %spontaneous(i) = spon;
        %spikesmean(i) = mean(nspikes);
        %spikespref(i) = max(nspikes);
        
        % correct for stimulator rotation if necessary
        %if (~isnan(rotated) & rotated)
        %    shift = -(rotated / 45);
        %    psp = circshift(psp, shift);
        %    nspikes = circshift(nspikes, shift);
        %end         
        
        % determine best angles
        if (max(ONspikes) > 0 & max(platspikes) > 0)
            [mx, mi] = max(ONspikes);
            bestAngleON(i) = stimuli(mi);
            [mx, mi] = max(platspikes);
            bestAnglePlat(i) = stimuli(mi);
            angleDiff(i) = DifferenceOfAngles(bestAngleON(i), bestAnglePlat(i));
        else
            bestAngleON(i) = NaN;
            bestAnglePlat(i) = NaN;
            angleDiff(i) = NaN;   
        end
    else
        bestAngleON(i) = NaN;
        bestAnglePlat(i) = NaN;
        angleDiff(i) = NaN;
    end
end

detach;
clear answers PWfile filtersize psp nspikes spon
