function writeTifStack(Y, filename)

imwrite(Y(:,:,1), filename);
for frNum = 1:size(Y,3)
    imwrite(Y(:,:,frNum), filename, 'writemode', 'append');
end