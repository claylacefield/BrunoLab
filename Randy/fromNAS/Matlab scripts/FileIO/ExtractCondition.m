function newcluster = ExtractCondition(cluster, condition)
% EXTRACTCONDITION Extract a stimulus condition.
%
% NEWCLUSTER = EXTRACTCONDITION(CLUSTER, CONDITION), where CLUSTER is a standard cluster
% dataset and CONDITION is a negative integer specifying a stimulus
% condition. NEWCLUSTER contains just the specified conditions. Trial
% numbers in NEWCLUSTER are renumbered to be consecutive; assumes that
% CLUSTER had nullspikes to encode all trials, even those without spikes.
%
% Randy Bruno, February 2006

% error checking
if nargin ~= 2
    error('ExtractCondition: requires 2 arguments');
end

if condition ~= floor(condition) | condition ~= ceil(condition) | condition > -1
    error('ExtractCondition: given condition not a negative integer');
end

% extract condition
stimuli = cluster(:, 3);
newcluster = cluster(stimuli==condition, :);
trial = newcluster(:, 2);

% renumber trials so they're consecutive
u = unique(trial);
for i = 1:length(u)
    newcluster(trial==u(i), 2) = i-1;
end
