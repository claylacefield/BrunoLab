function [meanAngle, medianAngle, totalFr, whiskMeasStruc] = extractBestWhiskerAnglesPhotFoc(basename, lengthThresh)

disp(['Loading ' basename '.measurements']);
tic;
measurements = LoadMeasurements([basename '.measurements']);
toc;

% load in necessary variables from measurements struc
disp('Loading in whisker measurements variables');
tic;
frNums = [measurements.fid]; %measurements = rmfield(measurements, 'fid');
%labels = [measurements.label];
lengths = [measurements.length]; %measurements = rmfield(measurements, 'length');
angles = [measurements.angle]; %measurements = rmfield(measurements, 'angle');
%follX = [measurements.follicle_x]; %measurements = rmfield(measurements, 'follicle_x');
%follY = [measurements.follicle_y];
toc; 

whiskerInfo.frNums = frNums;
whiskerInfo.lengths = lengths;
whiskerInfo.angles = angles;

whiskMeasStruc.whiskerInfo = whiskerInfo;

clear measurements;

totalFr = max(frNums)+1;
meanAngle = zeros(1,totalFr);
medianAngle = zeros(1,totalFr);

disp('Extracting average angles for longest two segments');
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
                medianAngle(frame) = median(angles(filtInd));
            else
                meanAngle(frame) = angles(filtInd);
                medianAngle(frame) = angles(filtInd);
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

clear lengths; clear angles; clear frNums; %clear follX; clear follY; 

% post-processing
% rma = runmean(meanAngle, 20);  % running mean to smooth out noise
% rma2 = rma-runmean(rma, 1000);  % and subtract a long-time baseline

% figure; hold on;
% plot(meanAngle);
% %plot(meanAngle, 'g');
% plot(medianAngle,'g');

whiskMeasStruc.meanAngle = meanAngle;
whiskMeasStruc.medianAngle =  medianAngle;
whiskMeasStruc.totalFr = totalFr;
whiskMeasStruc.lengthThresh = lengthThresh;
whiskMeasStruc.basename = basename;

save([basename '_whiskMeasStruc_' date], 'whiskMeasStruc');
