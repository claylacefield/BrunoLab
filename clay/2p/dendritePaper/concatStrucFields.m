function [outStruc] = concatStrucFields(inStruc, outStruc)

% Simple script to concatenate fields for structures with common fields
% Clay 050317


fields = fieldnames(inStruc);


for fieldNum = 1:length(fields)
    
    outStruc.(fields{fieldNum}) = [outStruc.(fields{fieldNum}) inStruc.(fields{fieldNum})];
    
end


