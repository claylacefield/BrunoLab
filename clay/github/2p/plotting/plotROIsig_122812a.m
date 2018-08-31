




figure;
hold on;
colorList = ['r' 'g' 'b' 'c' 'm' 'y'];

for i = 1:6
    caSig = data(i:6:end, 3);
    caSigAvg = mean(caSig,1);
    dF = (caSig - caSigAvg)/caSigAvg;
    stdF = std(dF);
    dF2 = dF/stdF;
    plot(dF2, colorList(i));
end