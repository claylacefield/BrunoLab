
% 011218
% plotting for adjusting itiWhiskBout parameters

rew = x2(3,:);
tw = tWhiskVidFrames;

ma4 = ma3/50;

stimTypeArr = eventStruc.correctRespStruc.stimTypeArr;
stimTimeArr = eventStruc.correctRespStruc.stimTimeArr;

figure;
plot(tw, ma4); 
hold on;
plot(rew, 'g');


for i = 1:length(stimTypeArr)
   text(stimTimeArr(i), 1, ['trial ' num2str(i) ': ' num2str(stimTypeArr(i))]); 
    
end

%plot(t(rewTime4), rew(rewTime4), 'r.');



frTimes = whiskDataStruc.frTimes;
itiWhiskPkTimes = whiskBoutCaStruc.itiWhiskPkTimes;
ipkInds = find(ismember(tw, itiWhiskPkTimes));

plot(tw(ipkInds), ma4(ipkInds), 'r*');
