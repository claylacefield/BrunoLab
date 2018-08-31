function [mdl] = RegressClayCalcium(x2, frameAvgDf)

%[poleonsetb, leverb, rewardb, punb, ncontact, nlick] = ProcessClayContinuousSignals(x2);
[poleonset, lever, reward, punish, ncontact, nlick, frameAvgDf] = ProcessClayContinuousSignals(x2, frameAvgDf);
ds = dataset(poleonset, lever, reward, punish, ncontact, nlick, frameAvgDf*100);
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