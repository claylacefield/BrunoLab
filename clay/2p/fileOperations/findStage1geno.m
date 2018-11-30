function [stage1cell] = findStage1geno()

% look through all cages and find sessions with Stage1 (lev task) data
genoPath = pwd;
n=0;
genoDir = dir;
for i=3:length(genoDir)
    try
        cd(genoDir(i).name);
        cageDir = dir;
        for j=3:length(cageDir)
            try
                cd(cageDir(j).name);
                mouseDir = dir;
                for k=3:length(mouseDir)
                    try
                        cd(mouseDir(k).name);
                        dayDir = dir;
                        for m=3:length(dayDir)
                            try
                                cd(dayDir(m).name);
                                txtFilename = findLatestFilename('.txt');
                                [programName] = readArduinoProgramName(txtFilename);
                                
                                if ~isempty(strfind(programName,'tage'))
                                   n=n+1;
                                   stage1cell{n,1} = cageDir(j).name; % mouse
                                   stage1cell{n,2} = mouseDir(k).name; % day
                                   stage1cell{n,3} = dayDir(j).name; % session
                                   load(findLatestFilename('dendriteBehavStruc'));
                                   stage1cell{n,4} = dendriteBehavStruc;
                                
                                
                                end
                            catch
                            end
                            cd([genoPath '/' genoDir(i).name '/' cageDir(j).name '/' mouseDir(k).name]);
                        end
                    catch
                    end
                    cd([genoPath '/' genoDir(i).name '/' cageDir(j).name]);
                end
            catch
            end
            cd([genoPath '/' genoDir(i).name]);
        end
    catch
    end
    cd(genoPath);
end
