
% 090114
% these are just some lines for plotting fractions of units with particular
% epoch rates/activity




% find the numbers of units that fall into particular quadrants

spm2 = length(find(epRate2(:,1) > 0 & epRate2(:,2) <0)); % for L2
smp2 = length(find(epRate2(:,1)< 0 & epRate2(:,2) > 0));
spp2 = length(find(epRate2(:,1) > 0 & epRate2(:,2) >0));
smm2 = length(find(epRate2(:,1)< 0 & epRate2(:,2) < 0));

spm4 = length(find(epRate4(:,1) > 0 & epRate4(:,2) <0)); % for L4
smp4 = length(find(epRate4(:,1)< 0 & epRate4(:,2) > 0));
spp4 = length(find(epRate4(:,1) > 0 & epRate4(:,2) >0));
smm4 = length(find(epRate4(:,1)< 0 & epRate4(:,2) < 0));

spm5 = length(find(unitEpochArr(:,1) > 0 & unitEpochArr(:,2) <0)); % for L5
smp5 = length(find(unitEpochArr(:,1) < 0 & unitEpochArr(:,2) >0));
spp5 = length(find(unitEpochArr(:,1) > 0 & unitEpochArr(:,2) >0));
smm5 = length(find(unitEpochArr(:,1) < 0 & unitEpochArr(:,2) <0));


% and plot these in a pie chart
figure; 
subplot(2,2,1); pie([spm2 smp2 spp2 smm2]);
subplot(2,2,2); pie([spm4 smp4 spp4 smm4]);
subplot(2,2,3); pie([spm5 smp5 spp5 smm5]);

% scatterplot of units based upon order in list (irrespective of session)

unitRewEpochArr = [];
unitRewEpochArr2 = [];
unitUnrewEpochArr = [];
unitUnrewEpochArr2 = [];


unitEpochArr = unitEpochCompilStruc.unitUnrewEpochArr;

figure; hold on;
numUnits = size(unitEpochArr, 1);

scatter(unitEpochArr(:,1), unitEpochArr(:,2), 3, 1:numUnits);

% for n = 1:numUnits
%   
%     scatter(unitEpochArr(n,1), unitEpochArr(n,2), 3, n/numUnits);
%    
% end

stimAvg = (unitEpochArr.unitRewEpochArr(:,2) + unitEpochArr.unitRewEpochArr(:,3))/2;

figure; hold on;
numUnits = size(unitEpochArr.unitRewEpochArr, 1);

% scatter(unitEpochArr.unitRewEpochArr(:,1), unitEpochArr.unitRewEpochArr(:,2), 3, 1:numUnits);

scatter(unitEpochArr.unitRewEpochArr(:,1), stimAvg, 3,...
    1:numUnits, 'MarkerFaceColor', 'b','MarkerEdgeColor', 'b');

line([0 0], get(gca, 'YLim'), 'Color', [0.6 0.6 0.6]);
line(get(gca, 'XLim'), [0 0], 'Color', [0.6 0.6 0.6]);

%%

stimAvg = (unitEpochArr.unitUnrewEpochArr(:,2) + unitEpochArr.unitUnrewEpochArr(:,3))/2;

figure; hold on;
numUnits = size(unitEpochArr.unitUnrewEpochArr, 1);

% scatter(unitEpochArr.unitRewEpochArr(:,1), unitEpochArr.unitRewEpochArr(:,2), 3, 1:numUnits);

scatter(unitEpochArr.unitUnrewEpochArr(:,1), stimAvg, 3, 1:numUnits);

line([0 0], get(gca, 'YLim'), 'Color', [0.6 0.6 0.6]);
line(get(gca, 'XLim'), [0 0], 'Color', [0.6 0.6 0.6]);

%%

% plot ep1/2 units by time (in color)

stimAvg = (unitEpochArr.unitRewEpochArr(:,2) + unitEpochArr.unitRewEpochArr(:,3))/2;

stimMax = max([unitEpochArr.unitUnrewEpochArr(:,2) unitEpochArr.unitUnrewEpochArr(:,3)]);

colors = jet(numUnits);

figure; hold on;

for unitNum = 1:numUnits
    plot(unitEpochArr.unitRewEpochArr(unitNum, 1), stimAvg(unitNum), 'b.', 'markers', 6); %, 'color', colors(unitNum, :), 'markers', 6);
    
    
end

line([0 0], get(gca, 'YLim'), 'Color', [0.6 0.6 0.6]);
line(get(gca, 'XLim'), [0 0], 'Color', [0.6 0.6 0.6]);




