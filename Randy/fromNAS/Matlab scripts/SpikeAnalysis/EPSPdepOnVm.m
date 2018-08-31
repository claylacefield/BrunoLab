% EPSP dependence on Vm

cluster = ReadCluster('c:\ntrode\031020\031020-41-thl\031020-41-thl.cluster1');
averagingpath = 'c:\ntrode\031020\031020-41-wcp-psp.dat';
%cluster = ReadCluster('c:\ntrode\030630\030630-28-thl\030630-28-thl.cluster1');
%averagingpath = 'c:\ntrode\030630\030630-28-wcp-psp.dat';
LIMIT = 50;
GreaterThan = 2; % rounded Vm must be equal to UpDownBorder
memoryless = 1;
winstart = 500;
winend = 2500;
trialStart = 0;
trialEnd = 1000;
TClockout = 50;
ShiftCorrect = 1;

firstV = -75;
lastV = -45;
stepV = 15;
V = firstV:stepV:lastV;
nV = length(V);

amp = zeros(nV, 1);
n = zeros(nV, 1);
for i = 1:nV
    [amp(i), n(i)] = STAanalysis(3000, cluster, averagingpath, LIMIT, V(i), V(i)+stepV, GreaterThan, memoryless, winstart, winend, trialStart, trialEnd, TClockout, ShiftCorrect);
end
