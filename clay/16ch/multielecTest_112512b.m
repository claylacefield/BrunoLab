

corrFirstContactTimes = corrFirstContactTimes(find(corrFirstContactTimes));

beginInd = corrFirstContactTimes - preFrame;
endInd = corrFirstContactTimes + postFrame;

for k = 1:length(endInd)
    
   %corrFirstContactLfp(:,:,k) = x(beginInd(k):endInd(k),:);
    corrFirstContactWhisk(:,k) = filtWhiskSig(beginInd(k):endInd(k));

%         for chNum = 1:size(x,2)
%             chDf = chStruc(:,chNum);
%             corrFirstContactLfp (:,chNum,k)= x(beginInd(k):endInd(k));
%             
%         end

    
end

epoch = sf*2:(sf*2+sf/10);
artThresh = 0.6;
m = 0;

for n = 1:size(corrFirstContactLfp, 3)
    if (max(abs(corrFirstContactLfp(epoch,4,n)))<artThresh)
        m=m+1;
        corrFirstContactLfp2(:,:,m) = corrFirstContactLfp(:,:,n);
    end
end

corrFirstContactLfp2Avg = mean(corrFirstContactLfp2,3);
    corrFirstContactLfpAvg = mean(corrFirstContactLfp,3);

for j=1:10
 figure; hold on; 
 for i = 1:16 
     plot(corrFirstContactLfp2(:,i,j)*2+i); 
 end
 
 %plot(corrFirstContactWhisk(:,j)*2-2, 'm');
 
end


figure; hold on; 
 for i = 1:16 
     plot(corrFirstContactLfp2Avg(:,i)*10+i); 
 end

 for i=1:16
     MyFilt1=fir1(100,[50 200]/Nyquist);
     filtLfpAvg(:,i) = filtfilt(MyFilt1,1,corrFirstContactLfp2Avg(:,i));
 end
 
 figure; hold on;
 for i = 1:16
     plot(filtLfpAvg(:,i)*10+i);
 end

 