

pun1 = dendriteBehavStruc.punTime1Ca;
%baseline = mean(pun1(1:8,:),2); 

for i = 1:size(pun1, 2)
   baseline = mean(pun1(1:8,i),1); 
   pun1b(:,i) = pun1(:,i) - baseline;
    
end



% plots signals along with normalized calcium

figure;

plot(x2(8,:)/5, 'r'); % plot pun
hold on;
plot(x2(3,:)/5, 'g'); % plot rew
plot(x2(6,:)/5, 'm'); % plot licks

C2 = C(:,goodSeg);
for segNum = 1:size(C2,2)
    
    normSeg = C2(:,segNum)/max(C2(:,segNum));
    plot(t(frameTrig), normSeg, 'y');

end

plot(x2(1,:)/5, 'c'); % plot trial start
plot(x2(5,:)/5, 'r'); % plot whisker contacts

normFrAv = frameAvgDf/max(frameAvgDf);
plot(t(frameTrig), normFrAv, 'g');

v = movingvar(mean_angle', 50);
plot(time*1000,v/100, 'b');