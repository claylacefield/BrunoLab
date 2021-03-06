function TS0 = Restrict(TS, t0, t1)

% ts/Restrict
% TS0 = Restrict(TS, t0, t1)
% 
% returns a new TS such that all timestamps in TS are between t0 and t1
%
% ADR
% version L4.0
% RELEASED as part of MClust 2.0
% See standard disclaimer in ../Contents.m

if size(t0) ~= size(t1)
   error('t0,t1 sizes do not match.');
end

f = [];
for iT = 1:length(t0)
   f = [f; find(TS.t >= t0(iT) & TS.t <= t1(iT))];
end
TS0 = ts(TS.t(f));
