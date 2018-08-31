

for goodNum = 1%:length(goodSeg)
        
    figure; hold on;
    plot(squeeze(segStruc.rewStimStimIndCa(:,goodSeg(goodNum),:)), 'b');
    plot(squeeze(segStruc.rewTime4Ca(:,goodSeg(goodNum),:)), 'r');
    title(['Seg #' num2str(goodSeg(goodNum))]);
end

%%

colors = jet(106);
for goodNum = 1%:length(goodSeg)
        
    figure; hold on;
    for i = 1:size(segStruc.rewStimStimIndCa, 3)
    plot(squeeze(segStruc.rewStimStimIndCa(:,goodSeg(goodNum),i)), 'Color', colors(i,:));
    end
    plot(squeeze(segStruc.rewTime4Ca(:,goodSeg(goodNum),:)), 'k');
    title(['Seg #' num2str(goodSeg(goodNum))]);
end


%%

colors = jet(10);
for goodNum = 1:length(goodSeg)
        
    figure; hold on;
    plot(squeeze(segStruc.rewStimStimIndCa(:,goodSeg(goodNum),:)), 'b');
    for i = 1:3
    plot(squeeze(segStruc.rewTime4Ca(:,goodSeg(goodNum),i)), 'Color', colors(i+7,:));
    end
    title(['Seg #' num2str(goodSeg(goodNum))]);
end
%%

for goodNum = 1:length(goodSeg)
    
    seg = goodSeg(goodNum);
    
    rew4 = segStruc.rewTime4RoiHist(:,seg);
    
    rew4post = rew4(9:20);
    
    sum4 = sum(rew4post);
    
    rew4pk(goodNum)=sum4;
    
    
    
    
end

rew4unInd = find(rew4pk >= 2);

figure; 
hold on; line([0 0.1], [0 0.1], 'Color', 'r');
scatter(unitEpochStruc.rewEpRate(:,1), unitEpochStruc.rewEpRate(:,2));
scatter(unitEpochStruc.rewEpRate(rew4unInd,1), unitEpochStruc.rewEpRate(rew4unInd,2), 'r');


%%

avRewStimIndCa = mean(segStruc.rewStimStimIndCa(:,goodSeg(2),:),3);

figure; pcolor(1:33,1:2,avRewStimIndCa'); shading interp;


