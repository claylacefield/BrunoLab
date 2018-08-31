function [pathStruc] = mouseTrack;
% this is a script for path analysis of mouse behavioral data
% Clay Lacefield
% 2008
% col8@columbia.edu

%RUN NOTE: you need to have both MATLAB Image Processing Toolbox, as well
%as "ait_centroid.m" (available from Mathworks exchange OR you can bypass
%this with a quick centroid calculation)

%INTERP NOTE: readings for situations in which mouse is mostly out of
%frame or when there are significant shadows may be off by up to 1cm

%PROGRAM NOTE: I need to build in a calibration factor to get readings in
%cm instead of pixels

%% BEGIN PROGRAM:
%first, we read in the video file (must be in AVI format)
%This makes the movie into a structure with fields (cdata and colormap)

tic
% load in structure of current directory
currDir = dir;

for m = 1:length(currDir)
    if strfind(currDir(m).name, '.avi')     % if file in directory in an AVI file
        mov = aviread(currDir(m).name);    % load in AVI file
        
        % initialize matrix of all frames of the movie
        mat = zeros(size(mov(1).cdata, 1), size(mov(1).cdata, 2), size(mov, 2));
        bwMat = uint8(zeros(size(mov(1).cdata, 1), size(mov(1).cdata, 2), size(mov, 2)));
        % mat = uint8(mat);
        map = mov(1).colormap;     % read colormap for interpreting uint8 indexed images

        % make matrix of all frames in the movie (can't read them all in separately
        % because I need to find the average for background calculation).
        for i=1:size(mov, 2)  % for every frame in the movie
            frame = mov(i).cdata; % read in a frame as an image
            %     imGray = ind2gray(frame,map);  % convert from indexed image to grayscale
            mat(:,:,i) = frame;
        end

        backgrd = mean(mat, 3);  % now determine the background as average of the frames
        % backgrd = uint8(backgrd);

        % now manipulate the frames, one at a time, to find mouse's position
        for j = 1:size(mov, 2)

            %take the difference of all the frames from the frame without mouse
            %     image = mat(:,:,j)-backgrd;    % subtract the background to isolate mouse
            im3 = imabsdiff(mat(:,:,j), backgrd); % this does sim thing a diff way

            %     %now enhance the contrast of the image
            % %     diff_im2 = imadjust(diff_im, [lowin;highin],[lowout; highout]);
%             im = histeq(uint8(image));
            
            im4 = (255 - mat(:,:,j)).*(im3./255);   %little trick for detecting mouse 

            % dilate the image to smooth noise (bars, some shadows, etc.)
            se1 = strel('ball', 5,5);   %sets imdilate pattern
            im5 = imdilate(im4, se1);  % dilate image

            %now threshold the image to create a binary image
            im6 = uint8(im5);   % must convert to uint8 for following operations
%             im3 = imadjust(dil8, [0.25;1], [0;1], 0.1);
            level = graythresh(im6);    % determines threshold level
            bw1 = im2bw(im6, level*1.6);  % convert to BW image / threshold

            % erode thresholded image to remove shadows and artifacts, tail, etc.
            se2 = strel('disk', 8,8);   % sets imerode pattern
%             bw2 = imerode(bw1,se2);          % erodes BW image to remove artifacts
%             bw2 = imerode(bw2,se2);
            se3 = strel('disk', 4,4);
            bw2 = imdilate(bw1, se3);       % now dilate to smooth

            bw3=imclose(bw2,se2);   % cleans up areas by eroding fjords
            bw4=bwareaopen(bw3,600);  % sets minimum size thresh for areas

%             figure; imagesc(mat(:,:,j).*bw2,[0 255]); colormap(gray);
%             %can look at overlay of detected region with mouse video
            
            % now extract position of mouse blob (NOTE:uses 3rd party script)
            [x y area] = ait_centroid(bw4);   % find centroid of binary, thresholded "mouse" image

            %now detect edges (don't need this now)
            %     outline = edge(BW, 'sobel'); % can also use 'canny' detection method

            % now tabulate x and y positions from the centroid detection
            xPos(j) = x;
            yPos(j) = y;
            mousArea(j) = area;    % record mouse area for error checking (no mouse)
            bwMat(:,:,j) = bw4;
        end     % ends loop for all frames of movie
        
        % error checking for strangely small areas (e.g. mouse out of
        % frame)
        for k = 1:length(mousArea)
            if mousArea(k)>(0.2*mean(mousArea))
                error(k) = 0;
            else error(k) = 1;
            end
        end
        
        if sum(error)>0
            isError = 'yes';
        else isError = 'no';
        end
        
        diffX = diff(xPos);     % finds difference in X/Y position between frames
        diffY = diff(yPos);
        distVec = ((diffX.^2 + diffY.^2)).^0.5;     % creates vector of distance moved between frames
        totalDist = sum(distVec)/size(mov,2);       % calculates total distance moved for all frames (per frame, if diff num frames)
        
        pathStruc(m).name = currDir(m).name;

        pathStruc(m).BWframes = bwMat;      %NOTE: take this out to reduce ouput file size (but you won't have the output frames)
        pathStruc(m).area = mousArea;
        pathStruc(m).error = error;
        pathStruc(m).isError = isError;
        pathStruc(m).position.xPos = xPos;      % loads mouse position from frame into output structure
        pathStruc(m).position.yPos = yPos;
        pathStruc(m).distVec = distVec;
        pathStruc(m).totalDist = totalDist;

    end     % ends IF loop looking for AVI files in directory (one behavioral group)

end     % ends FOR loop of all files in directory

toc
% figure; plot(xPos, -yPos);       % plot the resulting trajectory
% xLim([0 size(image,2)];
% yLim([0 size(image, 1)]);

%TAKE THIS OUT LATER!!!: plots nine frames for Dave's data only
% for p=1:size(pathStruc,2)
%     try
%     bwMat = [pathStruc(p).BWframes];
%     pos = [pathStruc(p).position];
%     xVec = [pos.xPos];
%     yVec = [pos.yPos];
%     animal = [pathStruc(p).name];
%     figure;
% %     title(animal);
%     for n = 1:size(bwMat, 3);
% %         if n==1
% %             title(animal);
% %         end
%         title(animal);
%         subplot(3,3,n);
%         imshow(bwMat(:,:,n)*255);   % need to mult. by 255 for some reason
%         ylabel(pathStruc(p).name);
%         hold on;
%         plot(xVec(n), yVec(n), ['x' 'r']);
%         if n~= 1
%             title(['frame #' num2str(n)]);
%         end
%         hold off;
%     end
%     catch
%     end
% end
