function [maskList] = makeMasks2(RoiList) 

%Generate Masks:
 
 if length(RoiList)==1
     currentROI=RoiList.mnCoordinates;
     xvalues = currentROI(:,1);
     yvalues = currentROI(:,2);
     maskList(:,:,1) = double(roipoly(128,128,xvalues,yvalues));
 else
     
        for z= 1:length(RoiList)
           
            currentROI = RoiList{z}.mnCoordinates;
            xvalues = currentROI(:,1);
            yvalues = currentROI(:,2);
            maskList(:,:,z) = double(roipoly(128,128,xvalues,yvalues));
        end
     
        
  % Parse out overlapping regions of ROIs    
  
        allmasks=sum(maskList,3);
        [row column value] = find(allmasks >1);
        for z=1:length(RoiList)
            for zz=1:length(value)
                maskList(row(zz),column(zz),z) = 0;
            end
        end
 end
 
%end