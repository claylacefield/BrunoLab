

for i = 1:length(rewStimCa)
   sessSegCa = rewStimCa{i};
   for seg = 1:size(sessSegCa,2)
       for evNum = 1:size(sessSegCa,3)
           segTrialCa = squeeze(sessSegCa(:,seg, evNum));
           if max(segTrialCa) >= (mean(segTrialCa(:))+std(segTrialCa(:)))
               
           end
       end
   end
end