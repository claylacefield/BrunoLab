function [groupStruc] = groupCompile(groupStruc, masterFieldNamesCaAvg, dendriteBehavStruc)

% this function compiles a number of different files for plotting paired
% responses between two groups (e.g. Layer5 somata and dendrites)

% % build output struc with all possible fields
% for field = 1:length(masterFieldNamesCaAvg)
%     groupSelStruc.(masterFieldNamesCaAvg{field}) = [];
% end

% append fields for each dendBehavStruc (if present, else skip)
for field = 1:length(masterFieldNamesCaAvg)
    try
        groupStruc.(masterFieldNamesCaAvg{field}) = [groupStruc.(masterFieldNamesCaAvg{field}) dendriteBehavStruc.(masterFieldNamesCaAvg{field})];
    catch
        %dbs.(masterFieldNamesCaAvg{field}) = [];
    end
    
end

