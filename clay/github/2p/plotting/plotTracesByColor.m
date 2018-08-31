function plotTracesByColor(x)

% this is a script to plot all traces in a set in color order

c = jet(size(x,2));

figure; hold on;

for i = 1:size(x,2)
    plot(x(:,i), 'Color', c(i,:));
end


