% test LRT.m

x = randn(1000,1);

% x = [randn(100,1); 2+randn(100,1)];

figure;
params2 = FitMixtureOfNormals(x);

p = LRT(x, @normpdf, @norm2pdf, {mean(x) std(x)}, num2cell(params2))