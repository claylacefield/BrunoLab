
function [numCoeffArr, posCoeffNamesArr, negCoeffNamesArr, maxPosCoeffNamesArr, RsqrArr, maxCoeffSegStruc] = segSelecAnal(segLinRegStruc, masterCoeffNames)

% this is a script to take linRegStruc and analyze complexity of the
% resulting models (numCoeff)

numCoeffArr = [];

posCoeffNamesArr = {};
negCoeffNamesArr = {};

RsqrArr = [];

goodPosCoeffNamesArr = {};
goodNegCoeffNamesArr = {};

maxPosCoeffNamesArr = {};

numCoeffSeg = 0;

% for all mice in struc
for numMouse = 1:size(segLinRegStruc.mouse,2)
    
    % for all sessions from this mouse (except first/stage1b)
    for numSession = 2:11 %size(segLinRegStruc.mouse(numMouse).session,2)
        
        % for all good dendrite segs
        for numSeg = 1:size(segLinRegStruc.mouse(numMouse).session(numSession).seg,2)
            
            % load in coeff names and vals for this seg from segLinRegStruc
            coeffNames = segLinRegStruc.mouse(numMouse).session(numSession).seg(numSeg).coeffNames;
            coeffDataset = segLinRegStruc.mouse(numMouse).session(numSession).seg(numSeg).coeff;
            
            % if there are any significant coeff for this dend
            if length(coeffNames) > 1
                
                Rsqr = segLinRegStruc.mouse(numMouse).session(numSession).seg(numSeg).Rsqr.Adjusted;
                RsqrArr = [RsqrArr Rsqr];
                
                % for all coeff (except the first/intercept)
                for numCo = 2:(length(coeffNames))
                    est = coeffDataset.Estimate(numCo);
                    
                    % tabulate positive and negative coeffNames
                    if est > 0
                        posCoeffNamesArr = [posCoeffNamesArr coeffNames(numCo)];
                        
                        if Rsqr > 0.3
                            goodPosCoeffNamesArr = [goodPosCoeffNamesArr coeffNames(numCo)];
                        end
                    else
                        negCoeffNamesArr = [negCoeffNamesArr coeffNames(numCo)];
                        if Rsqr > 0.3
                            goodNegCoeffNamesArr = [goodNegCoeffNamesArr coeffNames(numCo)];
                        end
                    end
                    
                end     % end FOR all coeff
                
                
                
                % and max positive coeff names
                
                estAll = coeffDataset.Estimate; % get all coeff vals
                [maxCoeffVal, maxCoeffInd] = max(estAll(2:end));    % find max (not including intercept)
                if maxCoeffVal > 0
                    maxPosCoeffNamesArr = [maxPosCoeffNamesArr coeffNames(maxCoeffInd+1)];  % concat max coeff name (adjusting for skipped intercept)
                    
                    % make struc with info for segs with particular
                    % selectivity
                    
                    if strcmp(coeffNames(maxCoeffInd+1), 'reward')
                        numCoeffSeg = numCoeffSeg + 1;
                        maxCoeffName = coeffNames(maxCoeffInd+1);
                        maxCoeffSegStruc(numCoeffSeg).name = segLinRegStruc.mouse(numMouse).session(numSession).name;
                        maxCoeffSegStruc(numCoeffSeg).maxCoeff = maxCoeffName{1};
                        maxCoeffSegStruc(numCoeffSeg).mouse = numMouse;
                        maxCoeffSegStruc(numCoeffSeg).session = numSession;
                        maxCoeffSegStruc(numCoeffSeg).seg = numSeg;
                        maxCoeffSegStruc(numCoeffSeg).Rsqr = Rsqr;
                    end
                    
                end
                
                
            end  % end IF there are signif coeff
            
            % and concat numCoeff (not including intercept)
            numCoeff = length(coeffNames)-1; % subtract 1 because first is always intercept
            numCoeffArr = [numCoeffArr; numCoeff];  % and just concatenate
            
        end     % end FOR loop for all segments (goodSeg)
        
    end     % end FOR loop for numSessions from an animal
end     % end FOR loop for all mice in a cage folder


[masterPosCoeffLog, masterPosCoeffInd] = ismember(posCoeffNamesArr, masterCoeffNames);
[masterNegCoeffLog, masterNegCoeffInd] = ismember(negCoeffNamesArr, masterCoeffNames);

[masterGoodPosCoeffLog, masterGoodPosCoeffInd] = ismember(goodPosCoeffNamesArr, masterCoeffNames);
[masterGoodNegCoeffLog, masterGoodNegCoeffInd] = ismember(goodNegCoeffNamesArr, masterCoeffNames);

[masterMaxPosCoeffLog, masterMaxPosCoeffInd] = ismember(maxPosCoeffNamesArr, masterCoeffNames);

% figure;
% subplot(3,1,1);
% hist(masterPosCoeffInd, 0:max(masterPosCoeffInd));
% h = findobj(gca,'Type','patch');
% set(h, 'FaceColor', 'b');
% title('masterPosCoeffInd');
% subplot(3,1,2);
% hist(masterNegCoeffInd, 0:max(masterNegCoeffInd), 'r');
% title('masterNegCoeffInd');
% subplot(3,1,3);
% hist(masterMaxPosCoeffInd, 0:max(masterMaxPosCoeffInd));
% h = findobj(gca,'Type','patch');
% set(h, 'FaceColor', 'b');
% title('masterMaxPosCoeffInd');
%
% figure;
% subplot(2,1,1);
% hist(masterGoodPosCoeffInd, 0:max(masterGoodPosCoeffInd));
% h = findobj(gca,'Type','patch');
% set(h, 'FaceColor', 'b');
% title('masterGoodPosCoeffInd');
% subplot(2,1,2);
% hist(masterGoodNegCoeffInd, 0:max(masterGoodNegCoeffInd));
% h = findobj(gca,'Type','patch');
% set(h, 'FaceColor', 'r');
% title('masterGoodNegCoeffInd');


