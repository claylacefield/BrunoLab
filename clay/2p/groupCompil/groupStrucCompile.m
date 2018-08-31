function [groupStruc] = groupStrucCompile(groupStruc, fieldNames, inStruc)

% this function is like groupCompile.m for calcium data but compiles a number of different files for plotting
% 160921: this new script compiles group structures, agnostic to the
% fieldnames (i.e. not using masterFieldNames). This won't work if some
% fields aren't present in some of the datasets though, I think.
% NOTE: that this concatenates all of the session averages in the different
% group members, not the average of these per animal.

% % build output struc with all possible fields
% for field = 1:length(masterFieldNamesCaAvg)
%     groupSelStruc.(masterFieldNamesCaAvg{field}) = [];
% end

% append fields for each dendBehavStruc (if present, else skip)
for field = 1:length(fieldNames)
    if isfield(groupStruc, fieldNames{field})
        try
            groupStruc.(fieldNames{field}) = [groupStruc.(fieldNames{field}) inStruc.(fieldNames{field})];
        catch
            %dbs.(masterFieldNamesCaAvg{field}) = [];
        end
    else
        groupStruc.(fieldNames{field}) = inStruc.(fieldNames{field});
    end
    
end

