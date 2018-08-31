function [paramEsts] = FitMixtureOfNormals(x, pStart)

% Fits a mixture of two normals.
% Randy Bruno, August 2009

pdf_normmixture = @(x,p,mu1,mu2,sigma1,sigma2) ...
                        p*normpdf(x,mu1,sigma1) + (1-p)*normpdf(x,mu2,sigma2);

% initial guesses
% pStart = .5; % initially 50-50 mixture
%muStart = quantile(x,[.25 .75])'; % initially normals centered on quartiles
muStart = quantile(x,[.1 .9])'; % initially normals centered on quartiles
% sigmaStart = sqrt(var(x) - .25*diff(muStart).^2); % initially equal
%start = [pStart muStart sigmaStart sigmaStart];
start = [pStart muStart sqrt(.1*var(x)) sqrt(.9*var(x))];

% lb = [0 -Inf -Inf 0 0];
% ub = [1 Inf Inf Inf Inf];
lb = [0 -80 -80 0 0];
ub = [1 -40 -40 Inf Inf];

% fits the model
options = statset('MaxIter',1000, 'MaxFunEvals',2000);
paramEsts = mle(x, 'pdf',pdf_normmixture, 'start',start, ...
                          'lower',lb, 'upper',ub, 'options',options);

% plots a histogram and fit
nbins = length(x) / 5;
nbins = min(100, nbins);
if min(x) > 0
    bins = linspace(0.9*min(x),1.1*max(x),nbins);
else
    bins = linspace(1.1*min(x),1.1*max(x),nbins);
end
binsize = bins(2)-bins(1);
h = bar(bins,histc(x,bins)/length(x),'histc');
set(h,'FaceColor',[.9 .9 .9]);
% pdfgrid = binsize * pdf_normmixture(bins,paramEsts(1),paramEsts(2),paramEsts(3),paramEsts(4),paramEsts(5));
pdfgrid = binsize * paramEsts(1)*normpdf(bins,paramEsts(2),paramEsts(4));
hold on; plot(bins,pdfgrid); hold off
pdfgrid = binsize * (1-paramEsts(1))*normpdf(bins,paramEsts(3),paramEsts(5));
hold on; plot(bins,pdfgrid,'r'); hold off