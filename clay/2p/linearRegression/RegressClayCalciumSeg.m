function [linRegStruc] = RegressClayCalciumSeg(ca, frameShift)

% frameAvgDf = dendriteBehavStruc.frameAvgDf;
% eventStruc = dendriteBehavStruc.eventStruc;

%[poleonsetb, leverb, rewardb, punb, ncontact, nlick] = ProcessClayContinuousSignals(x2);
[linRegSigStruc, frameAvgDf] = procLinRegSigs(); %frameAvgDf);

poleonsetb = linRegSigStruc.poleonsetb;
leverb = linRegSigStruc.leverb;
rewardb = linRegSigStruc.rewardb;
punb = linRegSigStruc.punb;
ncontact = linRegSigStruc.ncontact;
nlick = linRegSigStruc.nlick;
whiskAngle = linRegSigStruc.whiskAngle;

i = frameShift;

poleonset = circshift(poleonsetb, i);
lever = circshift(leverb, i); 
reward = circshift(rewardb, i); 
punish = circshift(punb, i); 
ncontact = circshift(ncontact, i);
nlick = circshift(nlick, i);
whiskAngle = circshift(whiskAngle, i);

ds = dataset(poleonset, lever, reward, punish, ncontact, nlick, whiskAngle, ca*100); %frameAvgDf*100);
%ds = dataset(poleonsetb, leverb, rewardb, punb, ncontact, nlick, frameAvgDf*100);
%ds =dataset(poleonset, lever, reward, punish, ncontact, nlick, segStruc.C(:,9)*100);


mdl = LinearModel.stepwise(ds, 'Verbose', 2);
% Use mdl.NumCoefficients to get # of elements in mode
% mdl.CoefficientNames to get names
% mdl.Coefficients returns estimates, SEs, etc.



% pure binary predictors - not as good
% contact = ncontact;
% contact(contact > 0) = 1;
% lick = nlick;
% lick(lick > 0) = 1;
% ds = dataset(poleonset, lever, reward, punish, ncontact, lick, frameAvgDf*100);
% mdl = LinearModel.stepwise(ds, 'Verbose', 2)


linRegStruc.mdl = mdl;
linRegStruc.frameShift = frameShift;
linRegStruc.linRegSigStruc = linRegSigStruc;