function plotUnitsByTime3(mouseUnitEpochSortStruc)

% in this version, smooth average rewStim Ca, then sort by time


%% Extract and process the caAvg data for all units
avCa = mouseUnitEpochSortStruc.rewStimCaAvg;

% for each unit processed in mouseUnitEpochSortStruc
for numSeg = 1:size(avCa,2)
    
    ca = avCa(:,numSeg);  % load in caAvg for this unit
    
    ca = (ca-mean(ca))/std(ca); % convert Ca to Zscores
    
    avCa2(:,numSeg) = interp1(-2:0.25:6,ca, -2:0.001:6); % interp to smooth
end

% find peak indices of scaled and smoothed caAvg data for all units
[pkValArr, pkIndArr] = max(avCa2(1:5000,:),[],1);

% now sort the scaled and smoothed caAvg data for all units
[sortedInd, origInd] = sort(pkIndArr);
avCaSort = avCa2(:,origInd);

%% Plotting

% plot sorted units w. heatmap
clims = [0.03 0.1];
figure; colormap(jet); imagesc(avCaSort', clims); 

% plot all the sorted units stacked
% figure; 
% hold on; 
% for i = 1:size(avCaSort,2)
%     plot(8*avCaSort(:,i)-i);
% end
% hold off;
