function segmentFolderAndSaveParDay2simaNew(K, beta, toSmooth, segDayThresh)

% USAGE: segmentCageAndSavePar2sima(K, beta, toSmooth)
% ARGUMENTS: 
% K = numFactors (e.g. 100)
% beta = sparseness penalty for nmf
% toSmooth = 1 to smooth tif stack before segmenting (otherwise 0)
% 



% setup parallel pool with 4 cores (of 16 on server)
% coresToUse = 4;
% parpool(coresToUse);

matlabpool open 4;
%poolobj = parpool(4);
%parpool(4);

% % select
% dayFolder = uigetdir;      % select the animal folder to analyze
% cd(dayFolder);
% %[pathname animalName] = fileparts(mouseFolder);
% dayDir = dir;

% 
% cageFolder = uigetdir;      % select the animal folder to analyze
% cd(cageFolder);
% %[pathname animalName] = fileparts(mouseFolder);
% cageDir = dir;
% 
% disp(['Parallel processing segmentation for cage ' cageFolder]);
% 
% for mouse = 3:length(cageDir)
%     
%     if cageDir(mouse).isdir && ~isempty(strfind(cageDir(mouse).name, 'mouse'))
%         
%         mouseName = cageDir(mouse).name;      % select the animal folder to analyze
%         mouseFolder = [cageFolder '/' mouseName];
        
        mouseFolder = uigetdir;
        
        cd(mouseFolder);
        [pathname, animalName] = fileparts(mouseFolder);
        mouseDir = dir;
        
        disp(['Processing ' animalName]);
        
        mouseDirLen = length(mouseDir);
        
        % parallel process each day of this mouse
        for a = 3:mouseDirLen % for each day of imaging in this animal's dir
            
            if mouseDir(a).isdir && ~isempty(strfind(mouseDir(a).name, '201'))
                
                dayFolder = [mouseFolder '/' mouseDir(a).name];
                cd(dayFolder);
                
                dayDir = dir;
                
                % go through all files/folders from this day
                
                parfor fileNum = 3:length(dayDir)  % for every file in day folder
                    
                    cd(dayFolder);
                    
                    if dayDir(fileNum).isdir   % if this is a folder
                        
                        tifFilename = dayDir(fileNum).name; % basename (w/o '.tif')
                        
                        cd(tifFilename);   % go there (session folder)
                        
                        fileDir = dir;
                        
                        fileNames = {fileDir.name}; % file names in current folder
                        dateNums = [fileDir.datenum];
                        
                        simaDir = [tifFilename '.sima'];
                        
                        % if there is a motion corrected folder
                        %if strmatch('corrected', fileNames)
                            
                            % look for latest segStruc and see if it has
                            % 100 factors (all new ones) CAN'T DO THIS W.
                            % PARFOR (load doesn't work?)
                            
                            disp(['Processing: ' tifFilename]);
                            
                            %try
                            segFileInd = find(not(cellfun('isempty', strfind(fileNames, 'seg2'))));
                            segFileDatenums = dateNums(segFileInd);
                            [maxSegDatenum, maxSegInd] = max(segFileDatenums);
                            %latestSegFileInd = segFileInd(maxSegInd);
                            %latestSegFilename = fileNames{latestSegFileInd};
                            
                            %load(latestSegFilename); can't use load in
                            %parfor
                            
                            if isempty(segFileInd)
                                maxSegDatenum = 0;
                            end
                            
                            %catch
                            %    disp('no previous seg2 files');
                            %    maxSegDatenum = 0;
                            %end
                            
                            % now just segment again if latest segStruc
                            % before Aug. 17, 2014 (all old style seg)
                            
                            % segDayThresh = 735870;
                            
                            if segDayThresh == 0 || maxSegDatenum < segDayThresh
                                toSegment = 1;
                            else
                                toSegment = 0;
                            end
                            
                            if toSegment == 1
                                
                                if strmatch(simaDir, fileNames)
                                    
                                    cd(simaDir);    % go to motion corrected dir
                                    
                                    motCorrDir = dir;
                                    motCorrFilenames = {motCorrDir.name};
                                    
                                    
                                    %tifFileNum = find(strcmp({motCorrDir.name}, ));
                                    
                                    %                             tifFileNum = strmatch('201', {motCorrDir.name});
                                    %
                                    %                             filename = motCorrDir(tifFileNum).name;
                                    
                                    % basename = filename(1:(strfind(filename, '.tif')-1));
                                    
                                    basename = tifFilename;
                                    filename = [basename '.tif'];
                                    
                                    
                                    
                                    if sum(cellfun(@length, strfind(motCorrFilenames, 'b.tif'))) ~= 0
                                        filename = [basename 'b.tif'];
                                    end
                                    
                                    disp(['nmf segmentation for ' filename]);
                                    %                     basename = filename(1:(strfind(filename, '.tif')-1));
                                    
                                    segStruc = struct;  % just initialize segStruc
                                    
                                    try
                                        %cd([dayPath basename '/corrected']);
                                        tic;
                                        %                 K = 50;
                                        %                 beta = 0.9;
                                        plotSeg = 0;
                                        sima = 1;
                                        segStruc = nmfBatchSmoothSima(filename, K, beta, plotSeg, toSmooth, sima);
                                        % C = segStruc.C;
                                        segStruc.K = K; segStruc.beta = beta; segStruc.toSmooth = toSmooth; segStruc.sima = sima;
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
                                        outName = [basename '_seg2_' date '.mat'];
                                        savePar(outName, segStruc);
                                        % clear segStruc;
                                    catch
                                        disp('no segStruc to save');
                                    end
                                    
                                end  % end IF sima dir exists
                                
                            else
                                disp('Recent seg2 file already exists');
                                
                            end % end IF latest segStruc datenum is before Aug. 17, 2014
                            
                        %end % end IF corrected exists
                        
                    end     % end IF folder.isdir
                    
                    %clear fileNames;
                    
                    cd(dayFolder);
                    
                end % end FOR loop for all files in dayDir
                
            end % end if(isdir)
            
            cd(mouseFolder);
            
        end % end for all days in mousedir
        
%     end % end if(isdir)
%     
%     cd(cageFolder);
%     
% end % end for all mice in cagedir

matlabpool close;
%delete(gcp);  % close current pool


function savePar(outName, segStruc)

save(outName, 'segStruc');

