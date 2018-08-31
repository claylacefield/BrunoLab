function [stimTrig] = extractStartTrigs(x2)

% This is a function to extract startTrigs from punSig when startSig is
% messed up (e.g. when LED is plugged in)

% binFilename = findLatestFilename('.bin');
% 
% x2 = binRead2pSingleName(binFilename);

punSig = x2(8,:);

pun2 = runmean(punSig, 20);

stimTrig = threshold(pun2, 0.12, 4000);

stimTrig = stimTrig - 120;  % need to adjust a bit because later scripts assume start trig a little bit before trials actually start

