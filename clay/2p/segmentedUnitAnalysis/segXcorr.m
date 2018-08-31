function [xcValArr, xcIndArr] = segXcorr(segStruc1, segStruc2, goodSeg1, goodSeg2)


% script to look through all xcorr2 of all segments from two days imaged at
% about the same depth to see distribution of xcorr2 values


A1 = segStruc1.A;
d11 = segStruc1.d1;
d12 = segStruc1.d2;

A2 = segStruc2.A;
d21 = segStruc2.d1;
d22 = segStruc2.d2;

xcValArr = [];
xcIndArr = [];

for i = 1:length(goodSeg1)
    A1a = reshape(A1(goodSeg1(i),:),d11,d12);
    
    A1a = A1a/max(A1a(:));
    
    tic;
    for j = 1:length(goodSeg2)
        A2a = reshape(A2(goodSeg2(j),:),d21,d22);
        
        A2a = A2a/max(A2a(:));
        
        disp(['XCORR2 of day 1 goodSeg# ' num2str(i) ' vs day2 goodSeg# ' num2str(j)]);
        
        cc = xcorr2(A1a, A2a);
        [max_cc, imax] = max(abs(cc(:)));
        
        xcValArr(i,j) = max_cc;
        xcIndArr(i,j) = imax;
    end
    toc
    
end

