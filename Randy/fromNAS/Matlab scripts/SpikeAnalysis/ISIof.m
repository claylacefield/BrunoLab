function y = ISIof(cluster)
% ISIOF Calculate ISIs.
%
% ISIOF(CLUSTER) calculates the ISIs of the spike data contained in
% cluster. The first spike of a trial is set to NaN since the time since
% the preceeding spike cannot be known.

x = cluster(:,4);
trial = cluster(:,2);

y = x(2:end) - x(1:(end-1));
y = [x(1) ; y];
	
% set the ISI of the first spike of each trial to NA
if (length(unique(trial)) > 1) 
    y([true ; (trial(2:end) ~= trial(1:(end-1)))]) = NaN;
else
    y(1) = NaN;
end