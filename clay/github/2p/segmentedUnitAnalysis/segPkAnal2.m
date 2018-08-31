
function [allSegTopFieldInd] = segPkAnal2(segPkStruc, masterFieldNames)


% this is a script to take segPkStruc and analyze the fields for each
% segment with the largest calcium peaks, over all animals

% output is a vector of the indices (with respect to masterFieldNames list)
% of all events with maximum calcium peaks, for all dendrite segments

%load('masterFieldNames2.mat');

allSegTopFieldInd = [];


for numMouse = 1:size(segPkStruc.mouse,2)
    
    for numSession = 1:size(segPkStruc.mouse(numMouse).session,2)
        
        caAvgPkVal = segPkStruc.mouse(numMouse).session(numSession).caAvgPkVal;
        fieldNames = segPkStruc.mouse(numMouse).session(numSession).fieldNames;
        
        %[maxEvVal,maxEvInd] = max(caAvgPkVal,[],1); % gives calcium pk value (over all events), and fieldNames index for this
        %maxEvField = fieldNames(maxEvInd); % gives pk fieldNames for each segment
        
        % now choosing top 4 events
        [sortPkVal, sortPkInd] = sort(caAvgPkVal,1, 'descend');
        
        
        for numSeg = 1:size(caAvgPkVal, 2)
            sortFieldNames = fieldNames(sortPkInd(:,numSeg));
            
            topFieldNames = sortFieldNames(1:4);
            
            % now find the master field indices for these max fields of the
            % segments
            [maxEvMasterLog, maxEvMasterInd] = ismember(topFieldNames, masterFieldNames);
            
            allSegTopFieldInd = [allSegTopFieldInd; maxEvMasterInd];
            
        end  % end FOR loop for all segments
        
    end
end


