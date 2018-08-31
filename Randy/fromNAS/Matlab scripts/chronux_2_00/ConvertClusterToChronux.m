function chronuxData = ConvertClusterToChronux(cluster)

% converts lab's standard cluster format (i.e., ouput of ReadCluster.m)
% to a data format appropriate for Chronux spike-related tools (i.e.,
% coherencypt)
%
% RMB, Feb 2011

% extract trials and timestamps from cluster structure
trials = cluster(:,2);
timestamps = cluster(:,4);
nspikes = nrows(timestamps);

% make sure freq.sampling is correctly specified by introducing 50 Hz
% artifact
% for i = 0:max(trials)
%     timestamps = [timestamps; 50; 70];
%     trials = [trials; i; i];
% end

chronuxData = struct('timestamps', {});
for i = 0:max(trials)
    % seconds rather than msecs
    chronuxData(i+1).timestamps = timestamps(trials == i) / 1000;
end
