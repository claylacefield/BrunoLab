% trying to write a script to capture serial event data from multiple
% arduinos

% open serial port
s = serial('com6'); % specify serial object for a particular port
fopen(s);   % must open a connection to this port in order to receive info

cellArr = {0};  % initialize cell array for string data from serial

% time/loop variables
tStart = clock;
duration = 0;
i = 0;
tic;    % start clock for trial duration

% record serial data from the arduinos for a time
while (duration <= 5)
    i = i+1;
    out = fscanf(s);    % read serial data
    
    %%% should put in section HERE to strip out serial data from different
    %%% boxes and strip out events in each of these streams (NOTE: may take
    %%% too much time and miss serial events???)
    
    cellArr{i} = out;   % record into cell array
    %duration = etime(clock, t);  % use etime to see duration of trial
    duration = toc;    % or use toc, I think this is better

end

tEnd = clock;   % see date,time when trial ends

% then close the serial port
fclose(s);
delete(s);
clear s;
