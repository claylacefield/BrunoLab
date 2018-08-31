function [goodSeg, goodSegParams] = findGoodSegsDG(segStruc)

% Clay 12/27/2016
% From segStruc of NMF output, 
% select factors that have features of neurons

% extract NMF spatial (A) and temporal (C) components
A = segStruc.A;
C = segStruc.C;
d1 = segStruc.d1;
d2 = segStruc.d2;

tempThreshSD = 2; %0.2;  % min temporal component
spatThreshHi = 1000; %500;  % max size
spatThreshLo = 9; %12;  % min size

goodSeg = [];   % initialize array of good segments

% look through all factors
for segNum = 1:size(C,2)
   segTemp = C(:,segNum);
   segSpat = A(segNum, :);
   
   tempThresh = tempThreshSD*std(segTemp)+mean(segTemp);
   
   bw = imbinarize(reshape(segSpat, d1,d2));  % binary image (for #pix in factor)
   
   % if factor has reasonable temporal and spatial features, add to array
   if max(segTemp) > tempThresh && sum(bw(:))<spatThreshHi && sum(bw(:))>spatThreshLo
      goodSeg = [goodSeg segNum]; 
   end
    
end

goodSegParams.tempThreshSD = tempThreshSD;
goodSegParams.spatThreshHi = spatThreshHi;
goodSegParams.spatThreshLo = spatThreshLo;