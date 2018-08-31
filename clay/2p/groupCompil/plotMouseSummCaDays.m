function plotMouseSummCaDays(somaDendTag, progNameTag, varargin);

%% USAGE: plotMouseSummCaDays(somaDendTag, progNameTag, varargin);
% varargin{1} = field1
% varargin{2} = field2
% varargin{3} = mouseSummCell

if length(varargin) == 0
    field1 = 'correctRewStimIndCa';
    field2 = 'correctUnrewStimIndCa';
    load(findLatestFilename('mouseSummCell'));
elseif length(varargin) == 2
    field1 = varargin{1};
    field2 = varargin{2};
    load(findLatestFilename('mouseSummCell'));
elseif length(varargin) == 3
    field1 = varargin{1};
    field2 = varargin{2};
    mouseSummCell = varargin{3};
end





numSess = size(mouseSummCell,1);
numFigs = ceil(numSess/25);

for i = 1:numFigs
    figure;
    for j = 1:5
        for k = 1:5
            try
            if ~isempty(strfind(mouseSummCell{25*(i-1)+5*(j-1)+k,6}, somaDendTag)) && ~isempty(strfind(mouseSummCell{25*(i-1)+5*(j-1)+k,7}, progNameTag))
                
                    subplot(5,5,5*(j-1)+k);
%                     rewCa = mouseSummCell{25*(i-1)+5*(j-1)+k,12};
%                     unrewCa = mouseSummCell{25*(i-1)+5*(j-1)+k,13};
                    
                    dbs = mouseSummCell{25*(i-1)+5*(j-1)+k,10};
                    rewCa = dbs.(field1);
                    unrewCa = dbs.(field2);
                    
                    plotMeanSEM(unrewCa, 'r');
                    hold on;
                    plotMeanSEM(rewCa, 'b');
                    %legend('unrew', 'rew');
                    title([mouseSummCell{25*(i-1)+5*(j-1)+k,3}]);
                    %xlabel('secs');
                    %ylabel('dF/F');
                    hold off;
            end
            catch
            end
        end
    end
end