

%% plot event avg over sessions (e.g. ca, % corr)
avgColNum = 12;

avgVals = [];

for i = 1:size(mouseSummCell,1)
    sessVals = mouseSummCell{i,avgColNum};
    avgVals = [avgVals nanmean(sessVals,2)];
    
end

%figure; 
plotTracesByColor(avgVals,1);

figure;
plot(max(avgVals(10:13,:)));


%% plot soma or dend peaks (or traces) over sessions
evVals = somaVals;
avgVals = [];

for i = 1:size(evVals,2)
    vals = evVals(10:13,2);
    avgVals = [avgVals nanmean(max(evVals(10:13,:)),2)];
    
end

figure;
plot(avgVals);

figure; 
plotTracesByColor(dendVals, 0);