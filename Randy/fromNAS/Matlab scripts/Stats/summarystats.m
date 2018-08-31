function summarystats(x)
% Computes summary statistics of x.
% Randy Bruno, April 2006

disp(['n = ' num2str(length(x(~isnan(x)))) ' (ignoring ' num2str(length(x(isnan(x)))) ' NaNs)']);
disp(['mean: ' num2str(nanmean(x)) ...
    ', SD: ' num2str(std(excise(x))) ...
    ', SE: ' num2str(stderr(x))]);
disp(['median: ' num2str(median(excise(x))) ...
    ', range : ' num2str([min(x) max(x)])]);
disp(' ');
