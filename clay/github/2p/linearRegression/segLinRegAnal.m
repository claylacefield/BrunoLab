
function [numCoeffArr] = segLinRegAnal(segLinRegStruc)

% this is a script to take linRegStruc and analyze complexity of the
% resulting models (numCoeff)

numCoeffArr = [];

for numMouse = 1:size(segLinRegStruc.mouse,2)
    
    for numSession = 1:size(segLinRegStruc.mouse(numMouse).session,2)
        
        for numSeg = 1:size(segLinRegStruc.mouse(numMouse).session(numSession).seg,2)
            
            coeffNames = segLinRegStruc.mouse(numMouse).session(numSession).seg(numSeg).coeffNames;
            
            numCoeff = length(coeffNames)-1; % subtract 1 because first is always intercept
            
            numCoeffArr = [numCoeffArr; numCoeff];  % and just concatenate
            
        end     % end FOR loop for all segments (goodSeg)
        
    end     % end FOR loop for numSessions from an animal
end     % end FOR loop for all mice in a cage folder


