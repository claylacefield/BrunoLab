function scatter1st2ndPk(dendriteBehavStruc)

% script to plot the 2nd peak times from a session
% Clay 102916

% select out rewDelay fields
rew1 = dendriteBehavStruc.rewDelay1TimeCaAvg;
rew2 = dendriteBehavStruc.rewDelay2TimeCaAvg;
rew3 = dendriteBehavStruc.rewDelay3TimeCaAvg;

% figure; plot(mean(rew1,2), 'b'); hold on; plot(mean(rew2,2), 'g'); plot(mean(rew3,2), 'r');
% figure; subplot(3,1,1); plot(rew1, 'b'); subplot(3,1,2); plot(rew2, 'g'); subplot(3,1,3); plot(rew3, 'r');

% now interp with spline fit 
t1 = -2:0.25:6;
t2 = -2:0.0625:6;

for trialNum = 1:size(rew1,2)
    rew1b(:,trialNum) = interp1(t1, rew1(:,trialNum), t2, 'spline');
end
for trialNum = 1:size(rew2,2)
    rew2b(:,trialNum) = interp1(t1, rew2(:,trialNum), t2, 'spline');
end
for trialNum = 1:size(rew3,2)
    rew3b(:,trialNum) = interp1(t1, rew3(:,trialNum), t2, 'spline');
end

% Find 1st, 2nd pks
% 1st pk 5-10fr, 2nd pk 11-18fr

[pk1rew1val, pk1rew1ind] = max(rew1b(20:40,:)); % 5:10
[pk1rew2val, pk1rew2ind] = max(rew2b(20:40,:));
[pk1rew3val, pk1rew3ind] = max(rew3b(20:40,:));

[pk2rew1val, pk2rew1ind] = max(rew1b(44:72,:)); % 11:18
[pk2rew2val, pk2rew2ind] = max(rew2b(44:72,:));
[pk2rew3val, pk2rew3ind] = max(rew3b(44:72,:));

% adjust indices for later reward delays
% pk1rew2ind = pk1rew2ind+19;
pk1rew2ind = pk1rew2ind+4;
pk1rew3ind = pk1rew3ind+8;
% pk2rew2ind = pk2rew2ind+43;
pk2rew2ind = pk2rew2ind+4;
pk2rew3ind = pk2rew3ind+8;

figure;
scatter(pk1rew1ind, pk1rew1val); hold on;
scatter(pk1rew2ind, pk1rew2val, 'g');
scatter(pk1rew3ind, pk1rew3val, 'r');
title('Pk 1');

figure;
scatter(pk2rew1ind, pk2rew1val); hold on;
scatter(pk2rew2ind, pk2rew2val, 'g');
scatter(pk2rew3ind, pk2rew3val, 'r');
title('Pk 2');

figure;
grp = [ones(1,length(pk2rew1ind)), 2*ones(1,length(pk2rew2ind)), 3*ones(1, length(pk2rew3ind))];
boxplot([pk2rew1ind, pk2rew2ind, pk2rew3ind], grp);