
% simple script for editing dataFileArray fields based upon animal

for numSess = 1:size(dataFileArray,1)
    
    if ~isempty(strfind(dataFileArray{numSess, 2}, 'R'))
        
       dataFileArray{numSess, 24} = 'Rbp4';
       
    elseif ~isempty(strfind(dataFileArray{numSess, 2}, 'N'))
        
        dataFileArray{numSess, 24} = 'Nr5a';
        
    elseif ~isempty(strfind(dataFileArray{numSess, 2}, 'X'))
        
        dataFileArray{numSess, 24} = 'Cux2';
        
    elseif ~isempty(strfind(dataFileArray{numSess, 2}, 'W'))
        
        dataFileArray{numSess, 24} = 'WfsI';
    end
    
    
%     if ~isempty(strfind(dataFileArray{numSess, 2}, 'W'))
%         
%         dataFileArray{numSess, 25} = 'unflexG6f';
%     else
%         dataFileArray{numSess, 25} = 'flexG6f';
%     end
    
    
end
