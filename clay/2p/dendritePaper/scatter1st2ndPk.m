function [pk2rew1ind, pk2rew2ind, pk2rew3ind] = scatter1st2ndPk(dendriteBehavStruc)

% script to plot the 2nd peak times from a session
% Clay 102916

% select out rewDelay fields
rew1 = dendriteBehavStruc.rewDelay1TimeCaAvg;
rew2 = dendriteBehavStruc.rewDelay2TimeCaAvg;
rew3 = dendriteBehavStruc.rewDelay3TimeCaAvg;

% figure; plot(mean(rew1,2), 'b'); hold on; plot(mean(rew2,2), 'g'); plot(mean(rew3,2), 'r');
% figure; subplot(3,1,1); plot(rew1, 'b'); subplot(3,1,2); plot(rew2, 'g'); subplot(3,1,3); plot(rew3, 'r');

interpFactor = 4;

% now interp with spline fit 
t1 = -2:0.25:6;
t2 = -2:0.25/interpFactor:6;

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

pk1range = [5 11];
pk2range = [12 18];

[pk1rew1val, pk1rew1ind] = max(rew1b((pk1range(1)*interpFactor):(pk1range(2)*interpFactor),:)); % 5:10
[pk1rew2val, pk1rew2ind] = max(rew2b((pk1range(1)*interpFactor):(pk1range(2)*interpFactor),:));
[pk1rew3val, pk1rew3ind] = max(rew3b((pk1range(1)*interpFactor):(pk1range(2)*interpFactor),:));

% [pk2rew1val, pk2rew1ind] = max(rew1b((pk2range(1)*interpFactor):(pk2range(2)*interpFactor),:)); % 11:18
% [pk2rew2val, pk2rew2ind] = max(rew2b((pk2range(1)*interpFactor):(pk2range(2)*interpFactor),:));
% [pk2rew3val, pk2rew3ind] = max(rew3b((pk2range(1)*interpFactor):(pk2range(2)*interpFactor),:));

% other method using LocalMinima
thresh = -0.001;
noCloserThan = 6;
j=0;

for i = 1:size(rew1,2)
    
    % subtract baseline
    r1b = rew1b(:,i)-min(rew1b(1:5*interpFactor,i));
    r2b = rew2b(:,i)-min(rew2b(1:5*interpFactor,i));
    r3b = rew3b(:,i)-min(rew3b(1:5*interpFactor,i));
    
    % find first peak
%     r1pk1 = LocalMinima(-r1b((pk1range(1)*interpFactor):(pk1range(2)*interpFactor),i), thresh, noCloserThan); % 5:10
%     r2pk1 = LocalMinima(-r2b((pk1range(1)*interpFactor):(pk1range(2)*interpFactor),i), thresh, noCloserThan); % 5:10
% 	r3pk1 = LocalMinima(-r3b((pk1range(1)*interpFactor):(pk1range(2)*interpFactor),i), thresh, noCloserThan); % 5:10
%     

    % and second peak (some may not have this)
    r1pk2 = LocalMinima(-r1b((pk2range(1)*interpFactor):(pk2range(2)*interpFactor)), thresh, noCloserThan); % 5:10
    r2pk2 = LocalMinima(-r2b((pk2range(1)*interpFactor):(pk2range(2)*interpFactor)), thresh, noCloserThan); % 5:10
	r3pk2 = LocalMinima(-r3b((pk2range(1)*interpFactor):(pk2range(2)*interpFactor)), thresh, noCloserThan); % 5:10
    
    if ~isempty(r1pk2) && ~isempty(r2pk2) && ~isempty(r3pk2)
        
        j = j+1;
    
%         firstPk11 = r1pk1(1);
%         pk1rew1ind(j) = firstPk11;
%         pk1rew1val(j) = r1b(firstPk11+(pk1range(1)*interpFactor)-1);
%         firstPk12 = r2pk1(1);
%         pk1rew2ind(j) = firstPk12;
%         pk1rew2val(j) = r2b(firstPk12+(pk1range(1)*interpFactor)-1);
%         firstPk13 = r3pk1(1);
%         pk1rew3ind(j) = firstPk13;
%         pk1rew3val(j) = r3b(firstPk13+(pk1range(1)*interpFactor)-1);
        firstPk21 = r1pk2(1);
        pk2rew1ind(j) = firstPk21;
        pk2rew1val(j) = r1b(firstPk21+(pk2range(1)*interpFactor)-1);
        firstPk22 = r2pk2(1);
        pk2rew2ind(j) = firstPk22;
        pk2rew2val(j) = r2b(firstPk22+(pk2range(1)*interpFactor)-1);
        firstPk23 = r3pk2(1);
        pk2rew3ind(j) = firstPk23;
        pk2rew3val(j) = r3b(firstPk23+(pk2range(1)*interpFactor)-1);
    
    end

end

% adjust indices for later reward delays (since avg based upon rew time)
% pk1rew2ind = pk1rew2ind+19;
pk1rew2ind = pk1rew2ind+1*interpFactor;
pk1rew3ind = pk1rew3ind+2*interpFactor;
% pk2rew2ind = pk2rew2ind+43;
pk2rew2ind = pk2rew2ind+1*interpFactor;
pk2rew3ind = pk2rew3ind+2*interpFactor;

% figure;
% scatter(pk1rew1ind, pk1rew1val); hold on;
% scatter(pk1rew2ind, pk1rew2val, 'g');
% scatter(pk1rew3ind, pk1rew3val, 'r');
% title('Pk 1');
% 
% figure;
% scatter(pk2rew1ind, pk2rew1val); hold on;
% scatter(pk2rew2ind, pk2rew2val, 'g');
% scatter(pk2rew3ind, pk2rew3val, 'r');
% title('Pk 2');

figure;
grp = [ones(1,length(pk2rew1ind)), 2*ones(1,length(pk2rew2ind)), 3*ones(1, length(pk2rew3ind))];
boxplot([pk2rew1ind, pk2rew2ind, pk2rew3ind], grp);
title('pk2 timing');

figure; 
plot([pk2rew1ind; pk2rew2ind; pk2rew3ind], '.-', 'MarkerSize', 18);
xlim([0.5 3.5]);