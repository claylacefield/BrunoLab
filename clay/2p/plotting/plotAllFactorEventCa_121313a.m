
K = segStruc.K;

figure;  % plot spatial components
for i = 1:K/2
    subplot(5,5,i); plot(squeeze(segStruc.correctUnrewStimIndCa(:,i,:)));
end


figure;  % plot spatial components
for i = (K/2+1):K
    subplot(5,5,i-25); plot(squeeze(segStruc.correctUnrewStimIndCa(:,i,:)));
end