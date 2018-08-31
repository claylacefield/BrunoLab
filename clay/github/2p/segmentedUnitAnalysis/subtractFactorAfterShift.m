function [subtFrame] = subtractFactorAfterShift(xpk1, ypk1, d1, d2, seg1, seg2)


%% USAGE:[subtFrame] = subtractFactorAfterShift(xpk1, ypk1, d1, d2, seg1, seg2);
%  This function is for use with segment cross correlation in order to see
%  whether the segmented factors are from the same dendritic tree
%  OUTPUT is the resulting spatial component after subtracting out the
%  shifted version (then other script sees how large the resulting is)

dispX = xpk1-d1; dispY = ypk1-d2;


if dispX > 0
    seg1b = [seg1; zeros(abs(dispX),size(seg1,2))];
    seg2b = [zeros(abs(dispX),size(seg2,2)); seg2];
elseif dispX < 0
    seg1b = [zeros(abs(dispX),size(seg1,2)); seg1];
    seg2b = [seg2; zeros(abs(dispX),size(seg2,2))];
else
    seg1b = seg1;
    seg2b = seg2;
end


if dispY > 0
    seg1c = [seg1b zeros(size(seg2b,1), abs(dispY))];
    seg2c = [zeros(size(seg2b,1), abs(dispY)) seg2b];
elseif dispY < 0
    seg1c = [zeros(size(seg1b,1), abs(dispY)) seg1b];
    seg2c = [seg2b zeros(size(seg2b,1), abs(dispY))];
else
    seg1c = seg1b;
    seg2c = seg2b;
end

subtFrame = seg1c-seg2c;

%figure; imagesc(subtFrame);

%disp(['mean subtFrame = ' num2str(mean(subtFrame(:)))]);
%disp(['max subtFrame = ' num2str(max(abs(subtFrame(:))))]);

