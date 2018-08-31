function [h] = BarSpecial(data, overallWidth, binSize )
    
%% from 
% http://stackoverflow.com/questions/12540438/how-to-increase-bar-width-without-overlapping-in-a-matlab-bar-graph

% This basically plots two bar series that are combined into "data" var
% NOTE: it also adjusts the time to correspond to the 250ms bins this data
% is divided up into


    colour = {'b','r'};
    [r,c] = size(data);
    h = zeros(c,1);
    width = overallWidth / c;
    offset = [-3*width/2 -width/2];
    
    figure;
    for i=1:c
        h(i) = bar(data(:,i),'FaceColor',colour{i},'BarWidth',width);   
        set(h(i),'XData',(get(h(i),'XData')+offset(i))*binSize/1000-2);
        hold on               
    end    
    
end