function [numCoeffArr, RsqrArr] = linRegAnal(linRegStruc, masterCoeffNames)


% this is a script to take linRegStruc and analyze complexity of the
% resulting models



numCoeffArr = [];
RsqrArr = [];

posCoeffNamesArr = {};
negCoeffNamesArr = {};
goodPosCoeffNamesArr = {};
goodNegCoeffNamesArr = {};

maxPosCoeffNamesArr = {};

for numMouse = 1:size(linRegStruc.mouse,2)
    
    for numSession = 1:size(linRegStruc.mouse(numMouse).session,2)
        
        coeffNames = linRegStruc.mouse(numMouse).session(numSession).mdl.CoefficientNames;
        Rsqr = linRegStruc.mouse(numMouse).session(numSession).mdl.Rsquared.Adjusted;
        coeffDataset = linRegStruc.mouse(numMouse).session(numSession).mdl.Coefficients;
        
        numCoeff = length(coeffNames);
        
        numCoeffArr = [numCoeffArr; numCoeff];
        
        RsqrArr = [RsqrArr Rsqr];
        
        % for all coeff (except the first/intercept)
        for numCo = 2:(length(coeffNames))
            est = coeffDataset.Estimate(numCo);
            
            % tabulate positive and negative coeffNames
            if est > 0
                posCoeffNamesArr = [posCoeffNamesArr coeffNames(numCo)];
                
                if Rsqr > 0.1
                    goodPosCoeffNamesArr = [goodPosCoeffNamesArr coeffNames(numCo)];
                end
            else
                negCoeffNamesArr = [negCoeffNamesArr coeffNames(numCo)];
                if Rsqr > 0.1
                    goodNegCoeffNamesArr = [goodNegCoeffNamesArr coeffNames(numCo)];
                end
            end
            
        end     % end FOR all coeff
        
        % and max positive coeff names
        
        estAll = coeffDataset.Estimate; % get all coeff vals
        [maxCoeffVal, maxCoeffInd] = max(estAll(2:end));    % find max (not including intercept)
        if maxCoeffVal > 0
            maxPosCoeffNamesArr = [maxPosCoeffNamesArr coeffNames(maxCoeffInd+1)];  % concat max coeff name (adjusting for skipped intercept)
        end
        
    end
end



[masterPosCoeffLog, masterPosCoeffInd] = ismember(posCoeffNamesArr, masterCoeffNames);
[masterNegCoeffLog, masterNegCoeffInd] = ismember(negCoeffNamesArr, masterCoeffNames);

[masterGoodPosCoeffLog, masterGoodPosCoeffInd] = ismember(goodPosCoeffNamesArr, masterCoeffNames);
[masterGoodNegCoeffLog, masterGoodNegCoeffInd] = ismember(goodNegCoeffNamesArr, masterCoeffNames);

[masterMaxPosCoeffLog, masterMaxPosCoeffInd] = ismember(maxPosCoeffNamesArr, masterCoeffNames);


figure; hist(RsqrArr);

figure;
subplot(3,1,1);
hist(masterPosCoeffInd, 0:max(masterPosCoeffInd));
h = findobj(gca,'Type','patch');
set(h, 'FaceColor', 'b');
title('masterPosCoeffInd');
subplot(3,1,2);
hist(masterNegCoeffInd, 0:max(masterNegCoeffInd), 'r');
title('masterNegCoeffInd');
subplot(3,1,3);
hist(masterMaxPosCoeffInd, 0:max(masterMaxPosCoeffInd));
h = findobj(gca,'Type','patch');
set(h, 'FaceColor', 'b');
title('masterMaxPosCoeffInd');

figure;
subplot(2,1,1);
hist(masterGoodPosCoeffInd, 0:max(masterGoodPosCoeffInd));
h = findobj(gca,'Type','patch');
set(h, 'FaceColor', 'b');
title('masterGoodPosCoeffInd');
subplot(2,1,2);
hist(masterGoodNegCoeffInd, 0:max(masterGoodNegCoeffInd));
h = findobj(gca,'Type','patch');
set(h, 'FaceColor', 'r');
title('masterGoodNegCoeffInd');

