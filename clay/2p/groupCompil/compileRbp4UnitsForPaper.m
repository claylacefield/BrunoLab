function [rbp4unitEpochStruc] = compileRbp4UnitsForPaper();

% Clay 2017

load('/home/clay/Documents/Data/2p mouse behavior/Rbp4/rewDelayGroup_44goodSess_012115a_datasetInfo_091215a.mat');

mouseNameCell = datasetInfoStruc.mouseNameCell;
sessionNameCell = datasetInfoStruc.sessionNameCell;
dbsFilenameCell = datasetInfoStruc.dbsFilenameCell;

numSeg = 0;
rewStimCaAvg = [];
rbp4unitEpochStruc = struct;
n=0;

for i = 1:length(sessionNameCell)
    mouseName = mouseNameCell{i};
    
    if strcmp(mouseName, 'mouseR101')
        cd('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R10a/mouseR101');
    elseif strcmp(mouseName, 'mouseR102')
        cd('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R10a/mouseR102');
    elseif strcmp(mouseName, 'mouseR103')
        cd('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R10b/mouseR103');
    elseif strcmp(mouseName, 'mouseR112')
        cd('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R11/mouseR112');
    end
    
    
    sessionName = sessionNameCell{i};
    dayName = sessionName(1:end-4);
    % tifName = filenameCell{i};
    cd([dayName '/' sessionName]);
    
    try % basically, some sessions don't have goodSeg, so this skips them
        goodSegName = findLatestFilename('goodSeg');
        load(goodSegName);
        disp(['Processing ' goodSegName]);
        numSeg = numSeg + length(goodSeg);
        
        segName = findLatestFilename('_seg_');
        load(segName);
        
        ca = segStruc.correctRewStimIndCaAvg(:,goodSeg);
        rewStimCaAvg = [rewStimCaAvg ca];
        
        [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg);
        n=n+1;
        rbp4unitEpochStruc(n).mouseName = mouseName;
        rbp4unitEpochStruc(n).sessionName = sessionName;
        rbp4unitEpochStruc(n).sessionPath = pwd;
        rbp4unitEpochStruc(n).goodSeg = goodSeg;
        rbp4unitEpochStruc(n).rewStimCaAvg = ca; %rewStimCaAvg;
        rbp4unitEpochStruc(n).unitEpochStruc = unitEpochStruc;
        rbp4unitEpochStruc(n).segStruc.rewTime4Ca = segStruc.rewTime4Ca(:, goodSeg, :);
        rbp4unitEpochStruc(n).segStruc.rewTime4RoiHist = segStruc.rewTime4RoiHist(:, goodSeg);
        rbp4unitEpochStruc(n).segStruc.rewTime4RoiHist2 = segStruc.rewTime4RoiHist2(:, goodSeg);
        rbp4unitEpochStruc(n).segStruc.isoLickTimeCa = segStruc.isoLickTimeCa(:, goodSeg, :);
        rbp4unitEpochStruc(n).segStruc.isoLickTimeRoiHist = segStruc.isoLickTimeRoiHist(:, goodSeg);
        rbp4unitEpochStruc(n).segStruc.isoLickTimeRoiHist2 = segStruc.isoLickTimeRoiHist2(:, goodSeg);
        
        %[rp4unitEpochStruc] = compileRbp4unitSegFields(rp4unitEpochStruc, segStruc, n);
    catch
        %break;
    end
    
end



figure('Position', [100 100 200 600]);
plotUnitsByTime4(rewStimCaAvg);


