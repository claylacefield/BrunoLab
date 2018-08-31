function [meanAngle] = reprocessWhiskMeas(whiskMeasStruc)

% This function reprocesses previously saved whisker measurement variables
% with new parameters (for tricky whisker data)

frNums = whiskMeasStruc.whiskerInfo.frNums;
lengths = whiskMeasStruc.whiskerInfo.lengths;
angles = whiskMeasStruc.whiskerInfo.angles;

totalFr = max(frNums);

tic;
for frame = 1:totalFr+1
    
    if mod(frame,10000) == 0
       disp(['Processing frame #' num2str(frame) ' out of ' num2str(totalFr)]);
        
    end
    
    %disp(['Processing frame #' num2str(frame) ' out of ' num2str(totalFr)]);
    %tic;
     try
        inds = find(frNums == frame-1); % find indices of all segments for this frame
        
        % find values for these whiskers and filter indices based upon these values
        frLengths = lengths(inds);
        lenInds = inds(find(frLengths >= lengthThresh));
        
%         frFollX = follX(inds);
%         follXinds = inds(find(frFollX <= 180));
%         
%         frFollY = follY(inds);
%         follYinds = inds(find(frFollY >= 250));
%         
%         % see which array indices meet all criteria
%         filtInd = intersect(lenInds, follXinds);
%         filtInd = intersect(filtInd, follYinds);
        
        filtInd = lenInds;

%         frLengths = lengths(filtInd);
%         [sortLen, sortLenInd] = sort(frLengths); % sort lengths to find largest two

%         meanAngle(frame) = mean(angles(filtInd));  % this is just average of all ok whiskers
%         medianAngle(frame) = median(angles(filtInd));
        
        % now average either two longest
        if length(filtInd)>= 1
            if length(filtInd) > 1
                meanAngle(frame) = mean(angles(filtInd));  % this is just average of all ok whiskers
                %medianAngle(frame) = median(angles(filtInd));
            else
                meanAngle(frame) = angles(filtInd);
                %medianAngle(frame) = angles(filtInd);
            end
        else
            meanAngle(frame) = meanAngle(frame-1);  % use last if something wrong
            %meanAngle1(frame) = meanAngle1(frame-1);  % use last if something wrong
        end
    catch
        disp(['Problem processing frame #' num2str(frame)]); % ' out of ' num2str(totalFr)]);
        try
        meanAngle(frame) = meanAngle(frame-1);  % use last if something wrong
        %meanAngle1(frame) = meanAngle1(frame-1);  % use last if something wrong
        catch
            meanAngle(frame) = 75;
        end
    end
    %toc;
end
toc;





