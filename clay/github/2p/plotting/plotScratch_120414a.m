

% these are just some random a la carte plotting routines 
% for some analysis 
% ~120314


% calculate segmented unit xcorr and plot (some or all xcorr?)

figure;

for numSeg1 = 1:10 % length(goodSeg)
    
    c1 = C(:,goodSeg(numSeg1));
    
    
    for numSeg2 = 1:10 % length(goodSeg)
        c2 = C(:,goodSeg(numSeg2));
        
        maxlags = 24;
        xc16 = xcorr(c1,c2, maxlags);
        subplot(10, 10, (numSeg1-1)*10+numSeg2);%length(goodSeg), length(goodSeg), numSeg1*(numSeg2-1)+numSeg2);
        plot(-maxlags:maxlags,xc16);
        
    end
    
end


% plot ITI whisk bout triggered segment Ca2+
% from segEventCa (output from itiWhiskBoutCa)

figure; 
for i = 1:length(goodSeg)
    subplot(8, ceil(length(goodSeg)/8), i);
    
    segCa = squeeze(segEventCa(:,i,:));
    sem = std(segCa')/sqrt(size(segCa,2));
    %errorbar(-2:0.25:6, mean(segCa,2), sem); 
    plot(-2:0.25:6,segCa)
    xlim([-2 2]);
    title(['seg = ' num2str(goodSeg(i))]); % ', lock=300,2sd']); 
end




% and for single seg
seg = 17;

figure;

i = find(goodSeg== seg);
%for i = 55 % 1:length(goodSeg)
%subplot(8, ceil(length(goodSeg)/8), i);
subplot(1, 2, 1);
segCa = squeeze(segEventCa(:,i,:));

plot(-2:0.25:6,segCa)
xlim([-2 2]);
title(['seg = ' num2str(goodSeg(i)) ', lock=100,1sd']);
%end

subplot(1, 2, 2);

sem = std(segCa')/sqrt(size(segCa,2));
errorbar(-2:0.25:6, mean(segCa,2), sem);

xlim([-2 2]);
title(['seg = ' num2str(goodSeg(i)) ', lock=100,1sd']);


% plot Ca traces with whisking peaks

figure; 
%plot(frameTrig, C(:,goodSeg)*200, 'y'); 
hold on;
plot(t, x2(1,:)*40, 'm');
plot(t2, v);
%plot(t2(wPks), v(wPks), 'r.');
plot(frameTrig, frameAvgDf*200, 'g');


figure; 
plotyy(frameTrig, frameAvgDf, t2(1:270000), v(1:270000));
