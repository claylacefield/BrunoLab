function [poleonsetb, leverb, rewardb, punb, ncontact, nlick, frameAvgDf] = processSignalsForRegression(eventStruc, frameAvgDf)

%
% Clay: this is a script based upon my older linear regression calculation
% however the event detection is now performed similar to the way I
% normally do it for my analyses (rather than how randy was detecting
% events). My way seems to do a better job at capturing relationships that
% can be observed in event-triggered averages...


% Key for continuous signals (var name "x2")
% 
% 1: stimulus triggers (~100ms before stimulus trial starts)
% 2: lever (pressed is ~4V, lifted is ~0.5)
% 3: reward
% 4: BOT whisker signal 
% 5: TOP whisker signal (this is one you want for test file)
% 6: lick signal
% 7: galvo signal (slow galvo)
% 8: punishment onset signal 
%
% sampled at 1 kHz


%% Pole onset

% poleonset = threshold(x2(1,:), 1, 100);
% % figure;
% % plot(x2(1,:));
% % text(poleonset, ones(length(poleonset),1), '*');
% poleonset = poleonset + 100; %correct temporal offset
% poleonset = poleonset;
% NOTE: this previous technique had looked at all start triggers, not just
% stimulus trials

rewStimStimInd = eventStruc.rewStimStimInd;
stimTrigTime = eventStruc.stimTrigTime;
rewStimTime = stimTrigTime(rewStimStimInd) + 300;
poleonset = rewStimTime;

%% Lever lifts

%leverlift = threshold(-x2(2,:), -1, 100);
% figure;
% plot(-x2(2,:));
% text(leverlift, -ones(length(leverlift),1), '*');

leverlift = eventStruc.levLiftTime;

%% Rewards (all types)

%reward = threshold(x2(3,:), 1, 100);
% figure;
% plot(x2(3,:));
% text(reward, ones(length(reward),1), '*');

reward = eventStruc.rewTime;

%% Punishments (white noise and timeout, mostly during catch trials)

%punish = threshold(x2(8,:), 1, 100);
% figure;
% plot(x2(8,:));
% text(punish, ones(length(punish),1), '*');

punish = eventStruc.punTime;


%% Whisker contacts

% figure
% plot(x2(5,:)); hold on;
% plot(diff(x2(5,:)), 'r')
%contact = threshold([0 diff(x2(5,:))], 0.3, 10);
%text(contact, ones(length(contact),1)*0.3, '*');

whiskContactCell1 = eventStruc.whiskContactCell1;
whiskContact = vertcat(whiskContactCell1{:});
whiskContact = whiskContact(whiskContact ~= 0);
contact = whiskContact;

%% Licks

%lick = threshold(x2(6,:), 1, 10);
%figure; plot(x2(6,:));
%text(lick, ones(length(lick),1), '*');

lick = eventStruc.lickTime;


%% 

%figure
%plot(x2(7,:)); hold on;
%plot(x2(1,:), 'r');
%frameedge = threshold(x2(7,:), -0.4, 10);

frameedge = eventStruc.frameTrig;

if length(frameedge) > length(frameAvgDf)
    frameedge = frameedge(1:length(frameAvgDf));
else
    frameAvgDf = frameAvgDf(1:length(frameedge));
end

dur = mean(diff(frameedge));
frameedge = [frameedge(1)-dur; frameedge];
%text(frameedge, zeros(length(frameedge),1), '*');

% clay: added this in to trim to correct length if randy's detects spurious
%frameedge = frameedge(1:(length(frameAvgDf)+1));

%% Create binary event vectors
nframes = length(frameedge) - 1;
poleonsetb = zeros(nframes, 1);
leverb = zeros(nframes, 1);
rewardb = zeros(nframes, 1);
punb = zeros(nframes, 1);
ncontact = zeros(nframes, 1);
nlick = zeros(nframes, 1);
for i = 1:nframes
    poleonsetb(i) = length(poleonset(poleonset >= frameedge(i) & poleonset < frameedge(i+1)));
    leverb(i) = length(leverlift(leverlift >= frameedge(i) & leverlift < frameedge(i+1)));
    rewardb(i) = length(reward(reward >= frameedge(i) & reward < frameedge(i+1)));
    punb(i) = length(punish(punish >= frameedge(i) & punish < frameedge(i+1)));
    ncontact(i) = length(contact(contact >= frameedge(i) & contact < frameedge(i+1)));
    nlick(i) = length(lick(lick >= frameedge(i) & lick < frameedge(i+1)));
end
%keep lever discretized
leverb(leverb > 0) = 1;
    