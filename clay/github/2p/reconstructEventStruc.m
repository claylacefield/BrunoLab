


% this script is to reconstruct event data from sessions in which I
% recorded over the TXT file in Processing

% Things I need to reconstruct
% 1.) trial type
% 2.) correct or incorrect
% 3.) skips or switches

% extract bottom whisker signal
whiskSig = x2(5,:);

wSig = whiskSig - runmean(whiskSig); % zero the mean

% find onset of unrew and rew trials
unrewStartTimes = threshold(wSig, 0.5, 3000);
rewStartTimes = threshold(-wSig, 0.8, 3000);

% make sure that this equals to trial number from trial start times

% sort the unrew/rew start times

% make stimTypeArr

% load in rew/pun times

% see which trials are correct/incorrect

% find random rewards (rewards not during trials)

% find experimenter rewards (trial rewards without animal response (lick or
% lever))

% find skip/switches (animal responses during trials not followed by
% rew/pun)










