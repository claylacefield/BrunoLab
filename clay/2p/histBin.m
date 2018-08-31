function [binSeries] = histBin(eventSeries, binSize)

%% USAGE: [binSeries] = histBin(eventSeries, binSize);
%  This function just bins some data (e.g. whisker contacts) into bins of a
%  certain binSize

% NOTE: for EventHist variables, this will already have been 
% converted to events/trial for each time bin (i.e. EventHist is
% probability of this event during a particular timebin (in ms) and this
% script will give cumulative probability for this event during a certain
% window = binSize

numBins = floor(length(eventSeries)/binSize);

for i = 1:numBins
    binSeries(i) = sum(eventSeries(((i-1)*binSize+1):i*binSize));
    
    
end




