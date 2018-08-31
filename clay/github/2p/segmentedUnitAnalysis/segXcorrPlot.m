function [segInd, pkInd] = segXcorrPlot() % xcValArr, segStruc1, segStruc2, goodSeg1, goodSeg2)


load('/home/clay/Documents/Data/analysis/segmented dendrites/xcArr_R50_021114b.mat');
cd('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R5/mouseR50/2013-06-10/2013-06-10-004');
load('2013-06-10-004_seg_06-Jan-2014.mat');
segStruc1 = segStruc;
load('goodSeg.mat');
goodSeg1 = goodSeg;

cd('/home/clay/Documents/Data/2p mouse behavior/Rbp4/R5/mouseR50/2013-06-12/2013-06-12-004');
load('2013-06-12-004_seg_06-Jan-2014.mat');
segStruc2 = segStruc;
load('goodSeg.mat');
goodSeg2 = goodSeg;

clear segStruc goodSeg;

numPks = 0;

% subtract mean of each signal
for i = 1:length(goodSeg1)
    
    xcva(i,:) = xcValArr(i,:) - mean(xcValArr(i,:));
    
end

% subtract mean of all signals
xcvAv = mean(xcva,1);

for i = 1:length(goodSeg1)
    
    xcva(i,:) = xcva(i,:) - xcvAv;  % subtract mean of all signals
    sdXc = std(xcva(i,:));
    pk = LocalMinima(-xcva(i,:), length(goodSeg2), -4*sdXc);
    
    if ~isempty(pk)
       numPks = numPks +1;
       segInd(numPks) = i;
       pkInd(numPks) = pk;
        
    end
    
end

t = 1:length(goodSeg2);

figure; hold on;
for i = 1:length(goodSeg1)
    
    xci = xcva(i,:)+i;
    
    plot(xci);
    
%     hasPk = find(segInd, i);
%     
%     if hasPk
%         plot(t(pkInd(hasPk)), xci(pkInd(hasPk)), 'r.');
%         
%     end
%     
%     clear hasPk;
    
end

for i=1:length(pkInd)
    xci = xcva(segInd(i),:)+segInd(i);
    plot(t(pkInd(i)), xci(pkInd(i)), 'r.');
    
end

A1 = segStruc1.A;
d11 = segStruc1.d1;
d12 = segStruc1.d2;

A2 = segStruc2.A;
d21 = segStruc2.d1;
d22 = segStruc2.d2;

for i=1:length(pkInd)
    figure;
    subplot(2,1,1); imagesc(reshape(A1(goodSeg1(segInd(i)),:),d11,d12)); 
    subplot(2,1,2); imagesc(reshape(A2(goodSeg2(pkInd(i)),:),d21,d22));
    
end

% for i = 1:length(pkInd)
%     for j = 1:length(pkInd)
%         [ypeak, xpeak] = ind2sub([219, 219], xcIndArr(segInd(i),pkInd(j)));
%         offset(i,j) = sqrt((ypeak-115)^2 + (xpeak -115)^2);
%     end
%     
% end
