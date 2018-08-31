function [inStruc] = compileFields(inStruc, behavStruc, size1)

fieldNames = fieldnames(inStruc);

for field = 1:length(fieldNames)
   try
       inStruc.(fieldNames{field}) = [inStruc.(fieldNames{field}) behavStruc.(fieldNames{field})];
   catch
       if ~isempty(strfind(fieldNames{field}, 'Avg')) || ~isempty(strfind(fieldNames{field}, 'Hist')) 
           inStruc.(fieldNames{field}) = [inStruc.(fieldNames{field}) NaN(size1,1)];
       end
   end
    
end


                                