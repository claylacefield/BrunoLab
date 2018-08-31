% this is a script for analyzing animal path info extracted from video
% using ImageJ

mouse1 = zeros((length(stack1(:,1))/2), 2); 
mouse2 = zeros((length(stack1(:,1))/2), 2);

for i = 1:length(stack1(:,1))
    if stack1(i,3) <= 180   % mouse in left half is mouse #1
        mouse1(i,1) = stack1(i,3);  % records mouse #1 X position
        mouse1(i,2) = stack1(i,4);  % records mouse #1 Y position
    else mouse1(i,1) = stack1(i,3); % likewise for mouse #2
        mouse1(i,2) = stack1(i,4);
    end
end