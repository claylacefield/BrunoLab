function [stage1cell] = findStage1geno()

% look through all cages and find sessions with Stage1 (lev task) data
genoPath = pwd;
n=0;
genoDir = dir;
for i=3:length(genoDir) % for all cages
    try
        cd(genoDir(i).name);
        cageDir = dir;
        for j=3:length(cageDir) % for all mice
            try
                cd(cageDir(j).name);
                mouseDir = dir;
                for k=3:length(mouseDir)    % for all days
                    try
                        cd(mouseDir(k).name);
                        dayDir = dir;
                        for m=3:length(dayDir)  % for all sessions
                            try
                                cd(dayDir(m).name);
                                binFilename = findLatestFilename('.bin');
                                txtFilename = [binFilename(1:strfind(binFilename, '.bin')-1) '.txt'];
                                [programName] = readArduinoProgramName(txtFilename);
                                
                                if ~isempty(strfind(programName,'tage'))
                                    
                                    
                                    %load(findLatestFilename('dendriteBehavStruc'));
                                    [dendriteBehavStruc] = dendriteBehavAnalysisSession();
                                    n=n+1;
                                    stage1cell{n,4} = dendriteBehavStruc;
                                    
                                    stage1cell{n,1} = cageDir(j).name; % mouse
                                    stage1cell{n,2} = mouseDir(k).name; % day
                                    stage1cell{n,3} = dayDir(m).name; % session
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
