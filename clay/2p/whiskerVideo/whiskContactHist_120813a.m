
rew1 = mean(batchWhiskHistStruc4hz.rewTime1WhiskSigAvg, 2);
rew5 = mean(batchWhiskHistStruc4hz.rewTime5WhiskSigAvg, 2);

binSize = 200;

for i = 0:((length(rew1)-(binSize+1))/binSize)
    rew1b(i+1) = sum(rew1((i*binSize+1):((i+1)*binSize)));
    rew5b(i+1) = sum(rew5((i*binSize+1):((i+1)*binSize)));
end

figure; 
subplot(1,2,1); bar(rew1b, 'c'); ylim([0 (max(rew5b)+0.5)]); xlim([0 length(rew1)/binSize]); 
subplot(1,2,2); bar(rew5b); ylim([0 (max(rew5b)+0.5)]); xlim([0 length(rew1)/binSize]);
