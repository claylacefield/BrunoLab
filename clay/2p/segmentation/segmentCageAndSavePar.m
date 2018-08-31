function segmentCageAndSavePar(K, beta)

% setup parallel pool with 4 cores (of 16 on server)
% coresToUse = 4;
% parpool(coresToUse);

% % select
% dayFolder = uigetdir;      % select the animal folder to analyze
% cd(dayFolder);
% %[pathname animalName] = fileparts(mouseFolder);
% dayDir = dir;


cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

disp(['Parallel processing segmentation for cage ' cageFolder]);

for mouse = 3:length(cageDir)
    
    if cageDir(mouse).isdir && ~isempty(strfind(cageDir(mouse).name, 'mouse'))
        
        mouseName = cageDir(mouse).name;      % select the animal folder to analyze
        mouseFolder = [cageFolder '/' mouseName];
        cd(mouseFolder);
        %[pathname animalName] = fileparts(mouseFolder);
        mouseDir = dir;
        
        disp(['Processing ' mouseName]);
        
        % parallel process each day of this mouse
        parfor a = 3:length(mouseDir) % for each day of imaging in this animal's dir
            
            if mouseDir(a).isdir && ~isempty(strfind(mouseDir(a).name, '201'))
                
                dayFolder = [mouseFolder '/' mouseDir(a).name];
                cd(dayFolder);
                
                dayDir = dir;
                
                % go through all files/folders from this day
                
                for fileNum = 3:length(dayDir)  % for every file in day folder
                    
                    if dayDir(fileNum).isdir   % if this is a folder
                        
                        tifFilename = dayDir(fileNum).name;
                        
                        cd(tifFilename);   % go there (session folder)
                        
                        fileDir = dir;
                        
                        fileNames = {fileDir.name}; % file names in current folder
                        
                        % if there is a motion corrected folder
                        if strmatch('corrected', fileNames)
                            
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
                            
                            cd ..;
                            
                            try
                                testName = segStruc.filename;
                                outName = [basename '_seg_' date '.mat'];
                                savePar(outName, segStruc);
                                % clear segStruc;
                            catch
                                disp('no segStruc to save');
                            end
                            
                            
                            
                        end % end IF
                        
                    end     % end IF folder.isdir
                    
                    %clear fileNames;
                    
                    cd(dayFolder);
                    
                end % end FOR loop for all files in dayDir
                
            end % end if(isdir)
            
            cd(mouseFolder);
            
        end % end for all days in mousedir
        
    end % end if(isdir)
    
    cd(cageFolder);
    
end % end for all mice in cagedir


function savePar(outName, segStruc)

save(outName, 'segStruc');

