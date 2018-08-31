function plotSegmentedFactor(segStruc)

% load in segmentation matrices
C = segStruc.C;     % temporal matrix
A = segStruc.A;     % spatial matrix
d1 = segStruc.d1;   % dimX?
d2 = segStruc.d2;   % dimY?
T = segStruc.T;     % time (num frames)
K = segStruc.K;
beta = segStruc.opt.beta;

%% Plot spatial factors and their temporal profiles

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