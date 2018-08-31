function plotUnitEpochCompil(unitEpochCompilStruc)

%
% Plotting function to use output from unitEpochCompilMouse


mouseName = unitEpochCompilStruc.mouseName;
goodGreatSeg = unitEpochCompilStruc.goodGreatSeg;

%try
    figure;
    subplot(2,1,1);
    scatter(unitEpochCompilStruc.unitRewEpochArr(:,2), unitEpochCompilStruc.unitRewEpochArr(:,1));
    hold on;
    line([0 0.1], [0 0.1], 'Color', 'r');
    title([mouseName ' ' goodGreatSeg 'Seg unitEpochScatter on ' date]);
    ylabel('Prestim epoch');
    xlabel('Poststim epoch 1');
    
    subplot(2,1,2);
    scatter((unitEpochCompilStruc.unitRewEpochArr(:,2)+unitEpochCompilStruc.unitRewEpochArr(:,3)), ...
        (unitEpochCompilStruc.unitUnrewEpochArr(:,2)+unitEpochCompilStruc.unitUnrewEpochArr(:,3)));
    hold on;
    line([0 0.1], [0 0.1], 'Color', 'r');
    %title([mouseName ' ' goodGreatSeg 'Seg unitEpochScatter on ' date]);
    xlabel('rew stim epochs');
    ylabel('unrew stim epochs');
    
    figure;
    scatter3(unitEpochCompilStruc.unitRewEpochArr(:,1), unitEpochCompilStruc.unitRewEpochArr(:,2), ...
        ((unitEpochCompilStruc.unitRewEpochArr(:,2)+unitEpochCompilStruc.unitRewEpochArr(:,3))./ ...
        (unitEpochCompilStruc.unitUnrewEpochArr(:,2)+unitEpochCompilStruc.unitUnrewEpochArr(:,3))));
    title([mouseName ' ' goodGreatSeg 'Seg unitEpochScatter on ' date]);
    
% catch
%     disp('Prob plotting');
% end






