
function [coeffNamesArr] = segLinRegAnal2(segLinRegStruc)

% this is a script to take linRegStruc and analyze complexity of the
% resulting models (numCoeff)

coeffNamesArr = {};

for numMouse = 1:size(segLinRegStruc.mouse,2)
    
    for numSession = 1:size(segLinRegStruc.mouse(numMouse).session,2)
        
        for numSeg = 1:size(segLinRegStruc.mouse(numMouse).session(numSession).seg,2)
            
            coeffNames = segLinRegStruc.mouse(numMouse).session(numSession).seg(numSeg).coeffNames;
            
            if length(coeffNames) > 1
            
            coeffNames = coeffNames(2); %:length(coeffNames));
            
            %numCoeff = length(coeffNames)-1; % subtract 1 because first is always intercept
            
            coeffNamesArr = [coeffNamesArr coeffNames];  % and just concatenate
            end
            
        end     % end FOR loop for all segments (goodSeg)
        
    end     % end FOR loop for numSessions from an animal
end     % end FOR loop for all mice in a cage folder


% so this will give the names of all the segment coefficients (however
% many, if any)

% now see how many of each type

%[masterCoeffLog, masterCoeffInd] = ismember(coeffNamesArr, masterCoeffNames);

