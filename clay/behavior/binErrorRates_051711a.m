


% script to calculate binned error rates over the entire session

minBin = 2;  % time base over which to calculate histograms (in minutes)
bin = minBin*60000; % bin size, in ms

for i= 1:length(correctRespStruc) 
    stimTimeArr = correctRespStruc(i).stimTimeArr;  % load in variable of trial times for this day
    lastTime = stimTimeArr(end);    % find last trial time
    lastTimeMinRound = ceil(lastTime/60000);  % find total number of minutes of session
    numBins = lastTimeMinRound/minBin;
    binFracMouse= zeros(length(correctRespStruc), lastTimeMinRound/minBin);

  for j=1:(lastTimeMinRound/minBin)  % for each timebin in trial
        
        % rewarded stimuli
        n=0; m=0;
        binRew = find(reward <= j*bin);   % finds all rewards up to this time (thus cumulative)
        binRewStim = find(rewStim <= j*bin);  % finds all reward opportunities up to this time
        n = length(binRew); % # rewards obtained in this timebin
        m = length(binRewStim); % # rewarded stimuli in this timebin
        if m ~= 0
            binFrac(j) = n/m;   % fraction of rewards per rewarded stim (cumulative)
        else
            binFrac(j) = 0; % if there were no rewarded stimuli, keeps from crashing
        end
        
  end
end
