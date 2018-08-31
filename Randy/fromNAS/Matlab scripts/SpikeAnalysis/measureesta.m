function measureesta(latency)

global stax
global stay


excerpt = stay(stax > 0 & stax < 15); % get the first 15 ms
peakval = max(excerpt);
peaktime = find(excerpt==peakval) / SCANSPERMS; % find the peak time in ms
    
baseline = stay(round(stax*10)==round(latency*10));
baseline = baseline(1); % determine baseline
amp = peakval - baseline; % calculate amplitude of PSP
twentyval = (amp * 0.2) + baseline; 
eightyval = (amp * 0.8) + baseline
    
twentytime = threshold(excerpt, twentyval, length(excerpt)) / SCANSPERMS
eightytime = threshold(excerpt, eightyval, length(excerpt)) / SCANSPERMS
disp(['20-80% risetime: ' num2str(eightytime - twentytime)]);

