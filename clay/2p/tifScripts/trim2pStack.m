function [Y, trimYX] = trim2pStack(Y)

if length(size(Y))>3
   Y = squeeze(Y);
end

[d1,d2,T]=size(Y);

tStart = tic;

disp('Calc diffStack');
tic;
dStack = Y(:,:,1:end-1)-Y(:,:,2:end);
toc;

minX = 0; maxX = d2;
minY = 0; maxY = d1;

disp('Calculating min boundaries');
tic;
for i = 1:size(dStack,3)
    
    diff1 = squeeze(dStack(:,:,i));
    diff1(isnan(diff1))=0;
    
    dim1 = runmean(movingvar(nanmean(diff1,1)', 4),3);
    dim2 = runmean(movingvar(nanmean(diff1,2), 4),3);
    
    
    hor_first = find(dim2(1:round(d2/2))==0,1,'last');
    hor_last = find(dim2(round(d2/2):end)==0,1,'first')+round(d2/2)-8;
    
    minX = max([minX hor_first]);
    maxX = min([maxX hor_last]);
    
    ver_first = find(dim1(1:round(d1/2))==0,1,'last')+8;
    ver_last = find(dim1(round(d1/2):end)==0,1,'first')+round(d1/2);
    
    minY = max([minY ver_first]);
    maxY = min([maxY ver_last]);
    
end
toc;

disp('Trimming stack...');
tic;
Y = Y(minY:maxY, minX:maxX, :);
toc;

disp('Total time elapsed:');
toc(tStart);

trimYX = [minY maxY; minX maxX];