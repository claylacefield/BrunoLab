





trialStart = stimTrig(1:(end-1)); % just cut off last trial since it may be incomplete


% select out epochs for sample and match stimuli (approximately)
% NOTE: this is established empirically by looking at the signals and might
% be off by 10ms or less (but this shouldn't be a huge issue)

beginSamp = trialStart + 300;
endSamp = beginSamp + 2000;

beginMatch = trialStart + 3000;
endMatch = beginMatch + 2000;

whisks = [whiskContacts1; whiskContacts2];
whisks = sort(whisks);

levs = [levPress; levLift];
levs = sort(levs);


for numTrial = 1:length(trialStart)
    sampLick(numTrial) = ~isempty(find(licks > beginSamp(numTrial) & licks < endSamp(numTrial)));
    matchLick(numTrial) = ~isempty(find(licks > beginMatch(numTrial) & licks < endMatch(numTrial)));
    
    sampWhisk(numTrial) = ~isempty(find(whisks > beginSamp(numTrial) & whisks < endSamp(numTrial)));
    matchWhisk(numTrial) = ~isempty(find(whisks > beginMatch(numTrial) & whisks < endMatch(numTrial)));
    
    sampLev(numTrial) = ~isempty(find(levs > beginSamp(numTrial) & levs < endSamp(numTrial)));
    matchLev(numTrial) = ~isempty(find(levs > beginMatch(numTrial) & levs < endMatch(numTrial)));

end

percSampLick = sum(sampLick)/length(sampLick)*100;
percMatchLick = sum(matchLick)/length(matchLick)*100;

percSampWhisk = sum(sampWhisk)/length(sampWhisk)*100;
percMatchWhisk = sum(matchWhisk)/length(matchWhisk)*100;

percSampLev = sum(sampLev)/length(sampLev)*100;
percMatchLev = sum(matchLev)/length(matchLev)*100;




