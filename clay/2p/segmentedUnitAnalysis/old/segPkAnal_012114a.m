
function [allSegMaxFieldInd] = segPkAnal(segPkStruc)


% this is a script to take segPkStruc and analyze the fields for each
% segment with the largest calcium peaks, over all animals

allSegMaxFieldInd = [];


for numMouse = 1:size(segPkStruc.mouse,2)
    
    for numSession = 1:size(segPkStruc.mouse(numMouse).session,2)
        
        caAvgPkVal = segPkStruc.mouse(numMouse).session(numSession).caAvgPkVal;
        fieldNames = segPkStruc.mouse(numMouse).session(numSession).fieldNames;
        
        [maxEvVal,maxEvInd] = max(caAvgPkVal,[],1); % gives calcium pk value (over all events), and fieldNames index for this
        
        maxEvField = fieldNames(maxEvInd); % gives pk fieldNames for each segment
        
        % now find the master field indices for these max fields of the
        % segments
        [maxEvMasterLog, maxEvMasterInd] = ismember(maxEvField, masterFieldNames);
        
        allSegMaxFieldInd = [allSegMaxFieldInd; maxEvMasterInd];
        
    end
end


