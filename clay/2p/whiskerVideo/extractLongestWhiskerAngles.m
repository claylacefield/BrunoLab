function [meanAngle] = extractLongestWhiskerAngles(measurements)


% load in necessary variables from measurements struc
disp('Loading in whisker measurements variables');
tic;
frNums = [measurements.fid];
%labels = [measurements.label];
lengths = [measurements.length];
angles = [measurements.angle];
toc; 

%clear measurements;

totalFr = max(frNums);
meanAngle = zeros(1,totalFr);

disp('Extracting average angles for longest two segments');
tic;
for frame = 1:totalFr+1
    
    disp(['Processing frame #' num2str(frame) ' out of ' num2str(totalFr)]);
    tic;
    try
        inds = find(frNums == frame-1); % find all segments for this frame
        frLengths = lengths(inds);
        [sortLen, sortLenInd] = sort(frLengths); % sort lengths to find largest two
        sortLenInd = sortLenInd(sortLen>100);
        
        if length(sortLenInd)>= 1
            if length(sortLenInd) > 1
                meanAngle(frame) = (angles(inds(sortLenInd(end))) + angles(inds(sortLenInd(end-1))))/2;
            else
                meanAngle(frame) = angles(inds(sortLenInd(1)));
                
            end
        else
            meanAngle(frame) = meanAngle(frame-1);  % use last if something wrong
        end
    catch
        meanAngle(frame) = meanAngle(frame-1);  % use last if something wrong
    end
    toc;
end
toc;



