
% thresholds for determining factor sameness
distThresh = 4;
pkThresh = 1.5;

A = segStruc.A;
% A is spatial information of 100 factors
d1 = segStruc.d1;   % dimensions of frame
d2 = segStruc.d2;
% d1 and d2 are dimensions of spatial info

C = segStruc.C;  % temporal components

goodSeg = [1 2 4 7 15 18 19 21 22 23 27 30 33 34 36 37 38 39 40 41 44 52 53 56 58 61 62 66 67 68 72 74 75 78 80 82 87 89 94 98 99];
Ag = A(goodSeg, :);
Cg = C(:, goodSeg);

% preallocate output matrices for speed
S = zeros(length(goodSeg), length(goodSeg));
pkMat = zeros(length(goodSeg), length(goodSeg));
dispMat = zeros(length(goodSeg), length(goodSeg));
subFactMat = zeros(length(goodSeg), length(goodSeg));
tCorrPkMat = zeros(length(goodSeg), length(goodSeg));

tic;
% loop through all goodSeg factors
for n = 1:length(goodSeg)
    tic;
    
    disp(['Factor ' num2str(n) ' xcorr2s']);
    
    for m = 1:length(goodSeg)
        
        % load in factors' spatial component
        seg1 = reshape(Ag(n,:), d1, d2);
        seg2 = reshape(Ag(m,:), d1, d2);
        
        
        segCorr = xcorr2(seg1,seg2); % 2D cross correlation
        [max1, max1ind] = max(abs(segCorr(:))); % find xcorr pk amplitude and location
        pkMat(n,m) = max1;  % save pk to mat
        [xpk1, ypk1] = ind2sub(size(segCorr,1), max1ind);   % find xy of pk
        %corr_offset = [ (xpk1-size(Ag1,1)) (ypk1 - size(Ag2,2)) ];
        d = sqrt((xpk1-d1)^2 + (ypk1-d2)^2);    % distance of pk from zero
        dispMat(n,m) = d;   % save dist in mat
        
        %dispX = xpk1-d1; dispY = ypk1-d2;
        
        [subtFrame] = subtractFactorAfterShift(xpk1, ypk1, d1, d2, seg1, seg2);
        % maybe max(abs(subtFrame(:))) should be < 1?
        % and/or mean(subtFrame(:)) > -0.005 ?
        
        subFactMax = max(abs(subtFrame(:)));
        subFactMat(n,m) = subFactMax;
        
        % and xcorr temp components as another measure
        seg1temp = Cg(:,n);
        seg2temp = Cg(:,m);
        
        % pk should be >5? if the same
        tCorrPk = max(xcorr(seg1temp, seg2temp, 'biased'));
        tCorrPkMat(n,m) = tCorrPk;
        
        % threshold values to determine if same cell/dendrite
        if d <= distThresh && max1 >= pkThresh
            disp('Similar factors');
            S(n,m) = 1;
            
            % but also add in other info for rare mistakes
            % (usually one small unit in same place as another)
            % in this case, if the spatial or temporal profiles
            % are too different
            
            if subFactMax > 1 || tCorrPk < 0.001
                S(n,m) = 2;
            end
            
        else
            disp('Dissimilar factors');
            S(n,m) = 0;
        end
        
        % just zero self-similarity
        if n==m
            S(n,m) = 0;
        end
        
    end
    toc;
end

disp('Total time elapsed');
toc;

                         
       