%Validate CompareIntercepts.m
%
% Run a number of simulations with data where the underlying intercepts are
% knon. Check that the right % show significant differences

n = 10000; % number of comparisons to run

p = nans(n, 1);
for i = 1:n
    
    x1 = 1:100;
    e1 = 1*randn(1,100);
    y1 = 1*x1 + 1 + e1;
    
    x2 = 1:100;
    e2 = 1*randn(1,100);
    y2 = -0.5*x2 + 0 + e2;
    
%     figure;
%     subplot(2,1,1);
%     plot(x1, y1);
%     subplot(2,1,2);
%     plot(x2, y2);
    
    p(i) = CompareIntercepts(x1, y1, x2, y2, 'different');
end

% fraction of simulations where the intercepts appeared different
% (false positives). This should be about 0.05, alpha, if intercepts are
% truly the same.
disp(['fraction sim with significant differences: ' num2str(sum(p < 0.05)/n)]); 
