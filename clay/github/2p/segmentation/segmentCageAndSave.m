function segmentCageAndSave(K, beta)



% select
dayFolder = uigetdir;      % select the animal folder to analyze
cd(dayFolder);
%[pathname animalName] = fileparts(mouseFolder);
dayDir = dir;


cageFolder = uigetdir;      % select the animal folder to analyze
cd(cageFolder);
%[pathname animalName] = fileparts(mouseFolder);
cageDir = dir;

for mouse = 3:length(cageDir)
    
    if cageDir(mouse).isdir
        
        mouseName = cageDir(mouse).name;      % select the animal folder to analyze
        mouseFolder = [cageFolder '/' mouseName];
        cd(mouseFolder);
        %[pathname animalName] = fileparts(mouseFolder);
        mouseDir = dir;
        
        
        for a = 3:length(mouseDir) % for each day of imaging in this animal's dir
            
            if mouseDir(a).isdir
                
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
                            
                            motCorrDir = dir;
                            
                            %tifFileNum = find(strcmp({motCorrDir.name}, ));
                            
%                             tifFileNum = strmatch('201', {motCorrDir.name});
%                             
%                             filename = motCorrDir(tifFileNum).name;
                            
                            % basename = filename(1:(strfind(filename, '.tif')-1));
                            
                            basename = tifFilename;
                            
                            disp(['nmf segmentation for ' tifFilename]);
                            %                     basename = filename(1:(strfind(filename, '.tif')-1));
                            
                            try
                                %cd([dayPath basename '/corrected']);
                                tic;
                                %                 K = 50;
                                %                 beta = 0.9;
                                plotSeg = 0;
                                segStruc = nmfBatch(filename, K, beta, plotSeg);
                                % C = segStruc.C;
                                segStruc.K = K; segStruc.beta = beta;
                                toc;
                            catch
                                disp(['Segmentation of ' filename ' failed']);
                                %C = [];
                            end
                            
                            cd ..;
                            
                            try
                                save([basename '_seg_' date '.mat'], 'segStruc');
                                clear segStruc;
                            catch
                                disp('no segStruc to save');
                            end
                            
                            
                            
                        end % end IF
                        
                    end     % end IF folder.isdir
                    
                    clear fileNames;
                    
                    cd(dayFolder);
                    
                end % end FOR loop for all files in dayDir
                
            end % end if(isdir)
            
        end % end for all days in mousedir
        
    end % end if(isdir)
    
end % end for all mice in cagedir