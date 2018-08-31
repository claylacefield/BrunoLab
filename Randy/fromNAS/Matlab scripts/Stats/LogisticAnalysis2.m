function LogisticAnalysis2(x, y, binwidth, xlab, ylab, plotcodes)

% LOGISTICANALYSIS(x, y, xlab, ylab, plotcodes) For binary Y response,
% performs logistic analysis using predictor X (continuous or discrete).
%
% x: vector encoding predictor variable
% y: vector encoding response variable (should be binary--0 and 1) or the
% predictor values for a second sample (see below)
% bindiwth: width of histogram bins (plotting only, doesn't affect stats)
% xlab: label for x-axes
% ylab: label for y-axes
% plotcodes: a 3-element vector. The first element is the number of rows
% in the current figure, the second the number of columns, and the third
% the column in which the results of this function should appear. This is
% useful for doing multiple analyses in a single figure window. MUST HAVE
% AT LEAST 4 ROWS.
%
% LogisticAnalysis.m - Randy Bruno, October 2003
%
% LogisticAnalysis2.m - updated Dec 2012 so that grid only affects plotting
% not stats). In LogisticAnalysis.m, the regression was on the binned
% histograms, not the raw data. Binned histograms are not entirely correct.

% CODE FOR GENERATING TEST DATA
% x = 1:100
% y = [binornd(1,.75, 50, 1); binornd(1, .25, 50, 1)] 

if nargin < 6
    plotcodes = [4 1 1];
end

prow = plotcodes(1);
pcol = plotcodes(2);
pn = plotcodes(3);

% If y is not a binary, then assume that y is a second sample and treat x
% as the values belonging to category 0 and y as belonging to category 1.
if length(y(y~=0 & y~=1))
    xx = [x; y];
    yy = [zeros(length(x), 1); ones(length(y), 1)];
    x = xx;
    y = yy;
end

x(x==Inf) = NaN;
y(y==Inf) = NaN;

% determine scaling/binning
maximum = ceil(max(x));
minimum = floor(min(x));
nbins = (maximum - minimum + 1) / binwidth;
if nbins < 5
    nbins = 5;
end
bins = linspace(minimum, maximum, nbins);
halfbin = binwidth / 2;

% histogram of failures (of response variable)
subplot(prow, pcol, pn);
fail = hist(x(y==0), bins)';
bar(bins, fail);
xlim([minimum-halfbin maximum+halfbin]);
ylabel(['n | ' ylab ' = 0']);
box off;

% histogram of successes
subplot(prow, pcol, pn+pcol);
success = hist(x(y==1), bins)';
bar(bins, success);
xlim([minimum-halfbin maximum+halfbin]);
ylabel(['n | ' ylab ' = 1']);
box off;

% plot the p(Y==1) vs X and fit a logistic regression
subplot(prow, pcol, pn+2*pcol);
%total = fail + success;
%p = success./total;
scatter(x, y);

[b, dev, stats] = glmfit(x, y, 'binomial', 'link', 'logit');
fit = glmval(b, bins, 'logit');
line(bins, fit, 'Color', 'r');
xlim([minimum-halfbin maximum+halfbin]);
xlabel(xlab);
ylabel(['p of ' ylab]);
box off;

% report some summary statistics of the logistic fit
subplot(prow, pcol, pn+3*pcol);
axis off;
text(0, .8, ['degrees of freedom = ' num2str(stats.dfe)]);
table = [stats.beta stats.t stats.p];
text(0, .6, 'beta         t          p');
text(0, .3, num2str(table));
text(0, 0, ['deviance = ' num2str(dev)]);

% for checking p by bin
%figure;
%plot(bins, success ./ (success+fail));
