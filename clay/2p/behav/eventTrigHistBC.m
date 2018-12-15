function [evTrigHist] = eventTrigHistBC(evTimes, sigTimes, varargin)

% This is the event-triggered histogram of events (like lick, whisk) for
% Barrel Cortex expts. ("BC")
% Clay Dec. 2018

% allow specification of binSize or interval
switch nargin
    case 2
        interval = [-2000 6000];
        binSize = 1;
    case 3
        if length(varargin{1})>1
            interval = varargin{1};
        else
            binSize = varargin{1};
        end
    case 4
        if length(varargin{1})>1
            interval = varargin{1};
            binSize = varargin{2};
        else
            interval = varargin{2};
            binSize = varargin{1};
        end
end


% pick out intervals around events
for i = 1:length(evTimes)
    try
    evSigInds = find(sigTimes>(evTimes(i)+interval(1)) & sigTimes<=(evTimes(i)+interval(2)));
    evSigIndsTrial = sigTimes(evSigInds) - (evTimes(i)+interval(1));
    evTrial = zeros(-interval(1)+interval(2),1);
    evTrial(evSigIndsTrial) = 1;
    evTrigHist(:,i) = evTrial;
    catch
    end
end

% figure;
% plotMeanSEMshaderr(runmean(evTrigHist,100), 'b');