function plotGoodSegs(segStruc, goodSeg)

% load in segmentation matrices
C = segStruc.C;     % temporal matrix
A = segStruc.A;     % spatial matrix
d1 = segStruc.d1;   % dimX?
d2 = segStruc.d2;   % dimY?
T = segStruc.T;     % time (num frames)
K = segStruc.K;
beta = segStruc.opt.beta;
filename = segStruc.filename;

%% Plot spatial factors and their temporal profiles

K = length(goodSeg);
A = A(goodSeg, :);
C = C(:,goodSeg);

if K > 25
numPlots = K/25;
else
    numPlots = 1;
end

for j = 1:numPlots
    
    figure;  % plot spatial components
    
    for i = 1:max(K,25)
        
        try
        subplot(5,5,i); imagesc(reshape(A(((j-1)*25+i),:),d1,d2)); axis equal; axis tight;
        catch
        end
        
        if i == 1
           title(['K = ' num2str(K) ' , beta = ' num2str(beta)]); 
        end
        
    end
    
    figure;  % plot temporal components
    for i = 1:max(K,25)
        try
        subplot(5,5,i); plot(C(:,((j-1)*25+i)));
        catch
        end
    end
    
end


%% Now plot all units together

% spatial
allSegIm = zeros(d1,d2);
for seg = 1:K
    allSegIm = allSegIm + reshape(A(seg,:),d1,d2);
end
figure; imagesc(allSegIm); hold on;

for seg = 1:K
    spat = A(seg,:);
    [pk, ind] = max(spat(:));
    [y,x] = ind2sub([d1 d2],ind);
    text(x,y, sprintf('%d', seg), 'Units', 'data');
end
title(filename);

% timecourse
figure; hold on;
for seg = 1:K
    plot(C(:,seg)+seg);
end
title(filename);
