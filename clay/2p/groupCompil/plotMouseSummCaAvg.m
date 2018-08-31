function plotMouseSummCaAvg(fields, sessList)


firstSess = sessList{1};
lastSess = sessList{2};

load(findLatestFilename('mouseSummCell'));

numSess = size(mouseSummCell,1);

ca1 = [];
ca2 = [];

sessLog = contains(mouseSummCell(:,3), sessList);

for i = 1:size(mouseSummCell,1)
    
    somaDend = mouseSummCell{i,6};
    
    progName = mouseSummCell{i,7};
    
    
    try
        rewCa = mouseSummCell{i,12};
        unrewCa = mouseSummCell{i,13};
        
    catch
    end
end
