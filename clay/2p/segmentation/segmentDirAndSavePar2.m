function segmentDirAndSavePar2(K, beta)

% setup parallel pool with 4 cores (of 16 on server)
% coresToUse = 4;
% parpool(coresToUse);

matlabpool open 4;

% % select
% dayFolder = uigetdir;      % select the animal folder to analyze
% cd(dayFolder);
% %[pathname animalName] = fileparts(mouseFolder);
% dayDir = dir;


mouseFolder = uigetdir;      % select the animal folder to analyze
cd(mouseFolder);
%[pathname animalName] = fileparts(mouseFolder);

%[pathname animalName] = fileparts(mouseFolder);
mouseDir = dir;

disp(['Processing ' mouseFolder]);

% parallel process each day of this mouse
parfor a = 3:length(mouseDir) % for each day of imaging in this animal's dir
    
    if mouseDir(a).isdir && ~isempty(strfind(mouseDir(a).name, '201'))
        
        dayFolder = [mouseFolder '/' mouseDir(a).name];
        cd(dayFolder);
        
        dayDir = dir;
        
        % go through all files/folders from this day
        
        for fileNum = 3:length(dayDir)  % for every file in day folder
            
            cd(dayFolder);
            
            if dayDir(fileNum).isdir   % if this is a folder
                
                tifFilename = dayDir(fileNum).name;
                
                cd(tifFilename);   % go there (session folder)
                
                fileDir = dir;
                
                fileNames = {fileDir.name}; % file names in current folder
                dateNums = [fileDir.datenum];
                
                % if there is a motion corrected folder
                if strmatch('corrected', fileNames)
                    
                    segFileInd = find(not(cellfun('isempty', strfind(fileNames, 'seg'))));
                    segFileDatenums = dateNums(segFileInd);
                    [maxSegDatenum, maxSegInd] = max(segFileDatenums);
                    % latestSegFileInd = segFileInd(maxSegInd);
                    % latestSegFilename = fileNames{latestSegFileInd};
                    
                    %load(latestSegFilename); can't use load in
                    %parfor
                    
                    % now just segment again if latest segStruc
                    % before Aug. 17, 2014 (all old style seg)
                    if isempty(maxSegDatenum)  %  maxSegDatenum < 7.3583e+05 || isempty(maxSegDatenum) 
                        
                        cd('corrected');    % go to motion corrected dir
                        
                        % motCorrDir = dir;
                        
                        %tifFileNum = find(strcmp({motCorrDir.name}, ));
                        
                        %                             tifFileNum = strmatch('201', {motCorrDir.name});
                        %
                        %                             filename = motCorrDir(tifFileNum).name;
                        
                        % basename = filename(1:(strfind(filename, '.tif')-1));
                        
                        basename = tifFilename;
                        filename = [basename '.tif'];
                        
                        disp(['nmf segmentation for ' filename]);
                        %                     basename = filename(1:(strfind(filename, '.tif')-1));
                        
                        segStruc = struct;
                        
                        try
                            %cd([dayPath basename '/corrected']);
                            tic;
                            %                 K = 50;
                            %                 beta = 0.9;
                            plotSeg = 0;
                            segStruc = nmfBatchSmooth(filename, K, beta, plotSeg);
                            % C = segStruc.C;
                            segStruc.K = K; segStruc.beta = beta;
                            segStruc.filename = filename;
                            toc;
                        catch
                            disp(['Segmentation of ' filename ' failed']);
                            
                            %C = [];
                        end
                        
                        %cd ..;
                        cd([dayFolder '/' tifFilename]);
                        
                        try
                            testName = segStruc.filename;
                            outName = [basename '_seg_' date '.mat'];
                            savePar(outName, segStruc);
                            % clear segStruc;
                        catch
                            disp('no segStruc to save');
                        end
                        
                    end
                    
                end % end IF corrected exists
                
            end     % end IF folder.isdir
            
            %clear fileNames;
            
            cd(dayFolder);
            
        end % end FOR loop for all files in dayDir
        
    end % end if(isdir)
    
    cd(mouseFolder);
    
end % end for all days in mousedir

matlabpool close;   % close pool of proc cores


function savePar(outName, segStruc)

save(outName, 'segStruc');

