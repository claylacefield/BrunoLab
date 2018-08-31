% Population PSP averages
%
% Randy Bruno, December 2003

SAMPLERATE = 32000;

answers = inputdlg({'Duration (msec)', 'Stimulus Onset (msec)', 'Window Start (msec)', 'Window End (msec)'}, 'Parameters for ISI analyses', 1, {'500', '145', '150', '200'});
duration = str2num(answers{1});
stimOnset = str2num(answers{2});
winstart = str2num(answers{3});
winend = str2num(answers{4});

data = xlsreadastext('C:\Documents and Settings\Randy Bruno\Desktop\analyses\urethane.xls'); %read data
attach;

n = length(Pwfile);

popAverage = zeros(duration * SAMPLERATE/1000, 1);
obs = 0;
for i = 1:n
    disp(['i = ', num2str(i), ': ', Pwfile{i}]);
    if (~isempty(Pwfile{i}) & ~strcmp(Pwfile{i}, 'NA') & isfinite(medfilt(i)) & strcmp(morph{i}, 'spiny') & layer(i)==4)
        % if there is a PW file listed and the data was filterable...
        % ...and spiny
        
        filepath = Pwfile{i};
        filepath = [filepath(1:(length(filepath)-4)) '-psp.dat'];
        
        figure;
        [cellAverages, x] = MeanContinuous(filepath, duration, stimOnset);
        %cellAverage = mean(cellAverages, 2);
        baselines = mean(cellAverages(x>1 & x<stimOnset, :), 1);
        peaks = mean(cellAverages(x>winstart & x<winend, :), 1);
        amplitudes = peaks-baselines;
        pmax = find(amplitudes == max(amplitudes));
        cellAverage = cellAverages(:, pmax);
        
        obs = obs + 1;
        popAverage = MemorylessAverage(popAverage, cellAverage, obs);
    end
end

figure;
plot(x, popAverage - mean(popAverage(1:(SAMPLERATE/1000*stimOnset))));
%plot(x, popAverage);

detach;
clear answers PWfile filtersize psp nspikes spon
