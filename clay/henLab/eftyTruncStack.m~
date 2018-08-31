function [Yt] = eftyTruncStack(Y)


disp('Truncating motion corrected stack'); tic;
[d1, d2, T] = size(Y);
d = d1*d2;
Yr = reshape(Y,d,T);
ff = find(isnan(Yr)); %find(Yr==0);
mask = reshape(full(logical(sparse(ff,1,1,d*T,1))),d1,d2,T);
se = ones(2,2,2);
mask2 = imopen(mask,se);
mask3d = mean(mask2,3);
BW = im2bw(mask3d,0.05);
hor_first = find(BW(round(d1/2),:)==0,1,'first');
hor_last = find(BW(round(d1/2),:)==0,1,'last');
ver_first = find(BW(:,round(d2/2))==0,1,'first');
ver_last = find(BW(:,round(d2/2))==0,1,'last');
Yt = Y(hor_first:hor_last,ver_first:ver_last,:);

toc;

disp('Setting other NaNs to mean of first frame'); tic;

avg = nanmean(Yt(1:d));
Yt(isnan(Yt)) = avg;

toc;