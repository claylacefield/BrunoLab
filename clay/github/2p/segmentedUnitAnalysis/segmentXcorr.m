function segmentXcorr()

% Segmentation Cross-Correlation Analysis
% Objective is to determine criteria if two factors are the same
% Factors are differeniated by peaks and displacement

% plotSegmentedFactor(segStruc);
% plots 100 factors spatial and temporal graphs

A = segStruc.A;
% A is spatial information of 100 factors
d1 = segStruc.d1;
d2 = segStruc.d2;
% d1 and d2 are dimensions of spatial info

goodSeg = [90, 99];
Ag = A(goodSeg, :);
Ag1 = reshape(Ag(1,:),d1,d2);
imagesc(Ag1);
Ag2 = reshape(Ag(2,:),d1,d2);
imagesc(Ag2);
x1b = xcorr2(Ag1, Ag2);
figure; image(x1b); 
h = max(max(x1b));
I = mat2gray(Ag1);
Ia = mat2gray(Ag2);
x1 = normxcorr2(I,Ia); 
figure; imagesc(x1); surf(x1), shading flat
matrixdisplacement = max(max(x1));

% offset found by correlation
[max_x1, imax] = max(abs(x1(:)));
[max_x1, imax] = max(abs(x1b(:)));
[ypeak, xpeak] = ind2sub(size(x1), imax(1));

% center of cross-correlation matrix in 2D is [d1, d2]

% distance between the offset and center
d = sqrt((xpeak - d1).^2 + (ypeak - d2).^2);

% h
% d



    




