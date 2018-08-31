function  [unitEpochCompilStruc] = unitEpochCompilMouse(fileTag, procSomaOrDend, goodGreatSeg);

% USAGE: [unitEpochCompilStruc] = unitEpochCompilMouse(fileTag, procSomaOrDend);
% NOTE: fileTag (behav program) can be either single fileTag to include or a 1x2 cell array of
% tag to include and tag to exclude (e.g {'Catch' 'sepChoice'} )
% procSomaOrDend = 's' to only take somata, 'd' dend, or 0 for either
% goodGreatSeg = 'good' to take goodSeg, or 'great' to take greatSeg
% OUTPUT:
% gives arrays of unit rates for 4 epoch in rew/unrew trials
% "2" denotes same analysis with events detected by another method

toPlot = 1;

mouseFolder = uigetdir;      % select the animal folder to analyze

mouseName = mouseFolder(strfind(mouseFolder, '/mouse')+1:end);

cd(mouseFolder);
%[pathname animalName] = fileparts(mouseFolder);
mouseDir = dir;

tic;

unitRewEpochArr = [];
unitRewEpochArr2 = [];
unitUnrewEpochArr = [];
unitUnrewEpochArr2 = [];

rewStimCaAvg = [];

session = 0;

for a = 3:length(mouseDir) % for each day of imaging in this animal's dir
    
    if mouseDir(a).isdir
        
        dayPath = [mouseFolder '/' mouseDir(a).name '/'];
        
        cd(dayPath); % go to this day of imaging
        
        dayDir = dir;
        
        for b = 3:length(dayDir)   % for each file in this day (now, folder with tif)
            
            cd(dayPath);
            
            if dayDir(b).isdir
                %% NEED TO ADD NEW LEVEL FOR TIF IN FOLDER FOR MOTION CORRECTION
                
                % see if this file is on the dataFileArray TIF list (and if so, what
                % row?)
                filename = [dayDir(b).name '.tif'];
                
                filename = filename(1:(strfind(filename, '.tif')+3));
                
                
                sessionName = dayDir(b).name;
                cd(sessionName);
                
                %if rowInd
                
                try
                    
                    %cd(dayPath);
                    
                    disp(['Processing: ' filename]);
                    tic;
                    
                    
                    %% see if correct somaDend (if desired)
                    if procSomaOrDend ~= 0  % if you want to look for somaDend
                        somaDendName = findLatestFilename('somaDend');
                        load(somaDendName, 'somaDend');
                        
                        if  contains(somaDend, procSomaOrDend)
                            toProcess = 1;
                        else
                            disp('Wrong somaDend');
                            toProcess = 0;
                        end
                        
                    else
                        toProcess = 1;
                    end
                    
                    %% and correct behavioral program
                    txtFilename = findLatestFilename('.txt');
                    programName = readArduinoProgramName(txtFilename);
                    
                    if iscell(fileTag)
                        progTag = fileTag{1};
                        progNotTag = fileTag{2};
                    else
                        progTag = fileTag;
                        progNotTag = 'nothing';
                    end
                    
                    if toProcess==1 && contains(programName, progTag) && ~contains(programName, progNotTag)
                        toProcess = 1;
                    else
                        toProcess = 0;
                    end
                        
                    % then process session
                    if toProcess
                        
                        
                        
                        % find latest segStruc for this session and load
%                         try
                        segFilename = findLatestFilename('_seg_');
                        load(segFilename);
%                         catch
%                             disp('No segStruc');
%                         end
                        
                        % and load in goodSeg
                        if contains(goodGreatSeg, 'good')
                            goodSegFilename = findLatestFilename('_goodSeg_');
                            load(goodSegFilename);
                        elseif contains(goodGreatSeg, 'great')
                            goodSegFilename = findLatestFilename('_greatSeg_');
                            load(goodSegFilename);
                            goodSeg = greatSeg;
                        end
                        
                        
                        
                        % now find the unit epoch rates for this session
                        [unitEpochStruc] = unitEpochClassif(segStruc, goodSeg);
                        
                        rewEpRate = unitEpochStruc.rewEpRate;
                        rewEpRate2 = unitEpochStruc.rewEpRate2;
                        unrewEpRate = unitEpochStruc.unrewEpRate;
                        unrewEpRate2 = unitEpochStruc.unrewEpRate2;
                        
                        unitRewEpochArr = [unitRewEpochArr; rewEpRate];
                        unitRewEpochArr2 = [unitRewEpochArr2; rewEpRate2];
                        unitUnrewEpochArr = [unitUnrewEpochArr; unrewEpRate];
                        unitUnrewEpochArr2 = [unitUnrewEpochArr2; unrewEpRate2];
                        
                        session = session + 1;
                        
                        sessNameCell{session} = sessionName;
                        numUnitsSess(session) = length(goodSeg);
                        
                        % now extract ca
                        rewCa = segStruc.correctRewStimIndCaAvg(:,goodSeg);
                        rewStimCaAvg = [rewStimCaAvg rewCa];
                        
                    else
                        disp('Wrong behav program or somaDend');
                    end
                    
                catch
                    disp(['Could not process: ' filename]);
                end
                
                toc;
                
                
                %end  % END IF this TIF folder is in dataFileArray
            end % END IF this is a directory (dayDir(b).isdir)
        end % END FOR loop looking through all files in this day's folder (for this animal)
        
    end   % END if isdir in home folder
    
end  % END searching through all days in animal folder

unitEpochCompilStruc.mouseName = mouseName;
unitEpochCompilStruc.mouseFolder = mouseFolder;
unitEpochCompilStruc.fileTag = progTag;
unitEpochCompilStruc.somaDend = procSomaOrDend;
unitEpochCompilStruc.goodGreatSeg = goodGreatSeg;

unitEpochCompilStruc.sessNameCell = sessNameCell;
unitEpochCompilStruc.numUnitsSess = numUnitsSess;

unitEpochCompilStruc.rewStimCaAvg = rewStimCaAvg;

unitEpochCompilStruc.unitRewEpochArr = unitRewEpochArr;
unitEpochCompilStruc.unitRewEpochArr2 = unitRewEpochArr2;
unitEpochCompilStruc.unitUnrewEpochArr = unitUnrewEpochArr;
unitEpochCompilStruc.unitUnrewEpochArr2 = unitUnrewEpochArr2;

cd(mouseFolder);

save(['unitEpochCompilStruc_' mouseName '_' progTag '_' procSomaOrDend '_' goodGreatSeg 'Seg_' date], 'unitEpochCompilStruc');

toc;

if toPlot
    try
        figure;
    subplot(2,1,1);
    scatter(unitEpochCompilStruc.unitRewEpochArr(:,2), unitEpochCompilStruc.unitRewEpochArr(:,1));
    hold on;
    line([0 0.1], [0 0.1], 'Color', 'r');
    title([mouseName ' ' goodGreatSeg 'Seg unitEpochScatter on ' date]);
    ylabel('Prestim epoch');
    xlabel('Poststim epoch 1');
    
    subplot(2,1,2);
    scatter((unitEpochCompilStruc.unitRewEpochArr(:,2)+unitEpochCompilStruc.unitRewEpochArr(:,3)), ...
        (unitEpochCompilStruc.unitUnrewEpochArr(:,2)+unitEpochCompilStruc.unitUnrewEpochArr(:,3)));
    hold on;
    line([0 0.1], [0 0.1], 'Color', 'r');
    %title([mouseName ' ' goodGreatSeg 'Seg unitEpochScatter on ' date]);
    xlabel('rew stim epochs');
    ylabel('unrew stim epochs');
    
    figure; 
    scatter3(unitEpochCompilStruc.unitRewEpochArr(:,1), unitEpochCompilStruc.unitRewEpochArr(:,2), ...
        ((unitEpochCompilStruc.unitRewEpochArr(:,2)+unitEpochCompilStruc.unitRewEpochArr(:,3))./ ...
        (unitEpochCompilStruc.unitUnrewEpochArr(:,2)+unitEpochCompilStruc.unitUnrewEpochArr(:,3))));
    title([mouseName ' ' goodGreatSeg 'Seg unitEpochScatter on ' date]);
    
    plotUnitsByTime3(unitEpochCompilStruc);
    
    
    catch
        disp('Prob plotting');
    end
end
